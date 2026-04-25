package com.example.rcbc_atm_go.topwise

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Typeface
import android.util.Log
import com.topwise.cloudpos.aidl.printer.AidlPrinter
import com.topwise.cloudpos.aidl.printer.AidlPrinterListener
import com.topwise.cloudpos.aidl.printer.Align
import com.topwise.cloudpos.aidl.printer.PrintTemplate
import com.topwise.cloudpos.aidl.printer.TextUnit
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

private const val TAG = "PrinterHandler"
private const val PRINTER_WIDTH_PX = 384
private const val LOGO_ASSET_PATH = "flutter_assets/assets/images/atm_go_logo.png"

class PrinterHandler(private val context: Context) {
    fun handle(call: MethodCall, result: MethodChannel.Result): Boolean {
        return when (call.method) {
            "printer/printReceipt" -> {
                printReceipt(call, result)
                true
            }
            else -> false
        }
    }

    private fun printReceipt(call: MethodCall, result: MethodChannel.Result) {
        val lines = call.argument<List<String>>("lines").orEmpty()
        val preLogoLines = call.argument<List<String>>("preLogoLines").orEmpty()
        val gray = call.argument<Int>("gray") ?: 3
        val alignName = call.argument<String>("align") ?: "LEFT"
        val textSize = call.argument<Int>("textSize") ?: 22
        val bold = call.argument<Boolean>("bold") ?: false
        val underline = call.argument<Boolean>("underline") ?: false

        val printer = DeviceServiceManager.getPrinter()
        if (printer == null) {
            result.error("PRINTER_UNAVAILABLE", "Topwise printer service is unavailable", null)
            return
        }

        try {
            val typeface = runCatching { Typeface.createFromAsset(context.assets, "topwise.ttf") }
                .getOrNull()
            val template = PrintTemplate.getInstance()

            val align = when (alignName.uppercase()) {
                "CENTER" -> Align.CENTER
                "RIGHT" -> Align.RIGHT
                else -> Align.LEFT
            }

            fun buildLines(lineList: List<String>) {
                template.init(context, typeface)
                template.clear()
                // Join all lines into a single TextUnit to avoid inter-unit spacing
                val combined = lineList.joinToString("\n")
                val textUnit = TextUnit("$combined\n", textSize).apply {
                    this.align = align
                    setBold(bold)
                    setUnderline(underline)
                    setWordWrap(true)
                }
                template.add(textUnit)
            }

            printer.setPrinterGray(gray)

            // 1. Pre-logo lines (e.g. CUSTOMER COPY header)
            if (preLogoLines.isNotEmpty()) {
                buildLines(preLogoLines)
                printer.addRuiImage(template.printBitmap, 0)
            }

            // 2. Logo bitmap
            val logoBitmap = loadLogoBitmap()
            if (logoBitmap != null) {
                printer.addRuiImage(logoBitmap, 0)
            } else {
                Log.w(TAG, "Logo bitmap could not be loaded; printing without logo")
            }

            // 3. Main receipt body
            buildLines(lines)
            printer.addRuiImage(template.printBitmap, 0)

            val printResult = waitForPrint(printer)
            if (printResult != null) {
                result.error("PRINT_FAILED", printResult, null)
            } else {
                result.success(mapOf("success" to true))
            }
        } catch (error: Exception) {
            result.error("PRINT_EXCEPTION", error.message, null)
        }
    }

    private fun loadLogoBitmap(): Bitmap? {
        return try {
            val stream = context.assets.open(LOGO_ASSET_PATH)
            val raw = BitmapFactory.decodeStream(stream)
            stream.close()
            if (raw == null) {
                Log.e(TAG, "BitmapFactory returned null for $LOGO_ASSET_PATH")
                return null
            }
            val scaledHeight = (raw.height * PRINTER_WIDTH_PX / raw.width.toFloat()).toInt()
            val scaled = Bitmap.createScaledBitmap(raw, PRINTER_WIDTH_PX, scaledHeight, true)
            // Thermal printers expect a white-background ARGB_8888 bitmap
            val output = Bitmap.createBitmap(PRINTER_WIDTH_PX, scaledHeight + 16, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(output)
            canvas.drawColor(Color.WHITE)
            canvas.drawBitmap(scaled, 0f, 8f, null)
            output
        } catch (e: Exception) {
            Log.e(TAG, "Failed to load logo: ${e.message}", e)
            null
        }
    }

    private fun waitForPrint(printer: AidlPrinter): String? {
        val latch = CountDownLatch(1)
        var failure: String? = null
        val listener = object : AidlPrinterListener.Stub() {
            override fun onError(code: Int) {
                failure = "Printer error code: $code"
                latch.countDown()
            }

            override fun onPrintFinish() {
                latch.countDown()
            }
        }

        printer.printRuiQueue(listener)
        val completed = latch.await(20, TimeUnit.SECONDS)
        if (!completed) {
            return "Printing timeout"
        }
        return failure
    }
}

package com.example.rcbc_atm_go.topwise

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Typeface
import android.os.Handler
import android.os.Looper
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

        // Run all blocking printer work on a background thread so the Android
        // main thread stays free for Flutter frame rendering (animation stays smooth).
        val mainHandler = Handler(Looper.getMainLooper())
        Thread {
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

                // 1. Header bitmap — CUSTOMER COPY text + logo combined into one
                //    (avoids the gap the SDK adds when starting a new bitmap block)
                val headerBitmap = loadHeaderBitmap(preLogoLines.joinToString("\n"))
                if (headerBitmap != null) {
                    printer.addRuiImage(headerBitmap, 0)
                } else {
                    Log.w(TAG, "Header bitmap could not be loaded; printing without header/logo")
                }

                // 2. Main receipt body
                buildLines(lines)
                printer.addRuiImage(template.printBitmap, 0)

                val printResult = waitForPrint(printer)
                // MethodChannel result must be delivered on the main thread
                mainHandler.post {
                    if (printResult != null) {
                        result.error("PRINT_FAILED", printResult, null)
                    } else {
                        result.success(mapOf("success" to true))
                    }
                }
            } catch (error: Exception) {
                mainHandler.post {
                    result.error("PRINT_EXCEPTION", error.message, null)
                }
            }
        }.start()
    }

    private fun loadHeaderBitmap(headerText: String): Bitmap? {
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

            val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.BLACK
                textSize = 24f
                textAlign = Paint.Align.CENTER
                typeface = Typeface.DEFAULT
            }

            // Measure each header text line so we know how tall the text block is
            val lines = if (headerText.isBlank()) emptyList() else headerText.split("\n")
            val lineHeight = (textPaint.descent() - textPaint.ascent()).toInt() + 4
            val textBlockHeight = if (lines.isEmpty()) 0 else lines.size * lineHeight + 8

            val totalHeight = textBlockHeight + scaledHeight + 8
            val output = Bitmap.createBitmap(PRINTER_WIDTH_PX, totalHeight, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(output)
            canvas.drawColor(Color.WHITE)

            // Draw each header line
            lines.forEachIndexed { index, line ->
                val y = 4f + (index + 1) * lineHeight - textPaint.descent()
                canvas.drawText(line.trim(), PRINTER_WIDTH_PX / 2f, y, textPaint)
            }

            // Draw logo below the text
            canvas.drawBitmap(scaled, 0f, textBlockHeight.toFloat(), null)
            output
        } catch (e: Exception) {
            Log.e(TAG, "Failed to load header bitmap: ${e.message}", e)
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

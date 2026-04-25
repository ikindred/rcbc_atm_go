package com.example.rcbc_atm_go.topwise

import android.content.Context
import android.graphics.Typeface
import com.topwise.cloudpos.aidl.printer.AidlPrinter
import com.topwise.cloudpos.aidl.printer.AidlPrinterListener
import com.topwise.cloudpos.aidl.printer.Align
import com.topwise.cloudpos.aidl.printer.PrintTemplate
import com.topwise.cloudpos.aidl.printer.TextUnit
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

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
        val gray = call.argument<Int>("gray") ?: 3
        val alignName = call.argument<String>("align") ?: "LEFT"
        val textSize = call.argument<Int>("textSize") ?: 18
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
            template.init(context, typeface)
            template.clear()

            val align = when (alignName.uppercase()) {
                "CENTER" -> Align.CENTER
                "RIGHT" -> Align.RIGHT
                else -> Align.LEFT
            }

            for (line in lines) {
                val textUnit = TextUnit("$line\n", textSize).apply {
                    this.align = align
                    setBold(bold)
                    setUnderline(underline)
                    setWordWrap(true)
                }
                template.add(textUnit)
            }

            printer.setPrinterGray(gray)
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

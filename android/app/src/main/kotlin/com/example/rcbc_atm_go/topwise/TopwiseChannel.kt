package com.example.rcbc_atm_go.topwise

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class TopwiseChannel(private val context: Context) {
    companion object {
        const val METHOD_CHANNEL = "topwise/device"
        const val EVENT_CHANNEL = "topwise/cardEvents"
    }

    private val cardReaderHandler = CardReaderHandler()
    private val printerHandler = PrinterHandler(context)

    fun register(flutterEngine: FlutterEngine) {
        DeviceServiceManager.init(context)
        DeviceServiceManager.bindDeviceService()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
            .setMethodCallHandler { call, result ->
                when {
                    printerHandler.handle(call, result) -> Unit
                    cardReaderHandler.handle(call, result) -> Unit
                    else -> result.notImplemented()
                }
            }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
            .setStreamHandler(cardReaderHandler)
    }
}

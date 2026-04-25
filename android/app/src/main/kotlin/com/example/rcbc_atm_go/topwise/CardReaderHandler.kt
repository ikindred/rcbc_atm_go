package com.example.rcbc_atm_go.topwise

import android.os.RemoteException
import com.topwise.cloudpos.aidl.emv.AidlCheckCardListener
import com.topwise.cloudpos.aidl.magcard.TrackData
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class CardReaderHandler : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null

    fun handle(call: MethodCall, result: MethodChannel.Result): Boolean {
        return when (call.method) {
            "card/startSwipe" -> {
                startSwipe(call, result)
                true
            }
            "card/stopSwipe" -> {
                stopSwipe(result)
                true
            }
            "card/startIC" -> {
                startIC(result)
                true
            }
            "card/stopIC" -> {
                stopIC(result)
                true
            }
            "card/isICPresent" -> {
                isICPresent(result)
                true
            }
            "card/resetIC" -> {
                resetIC(result)
                true
            }
            "card/readICApdu" -> {
                readICApdu(call, result)
                true
            }
            "card/startRF" -> {
                startRF(result)
                true
            }
            "card/stopRF" -> {
                stopRF(result)
                true
            }
            "card/pollRF" -> {
                pollRF(result)
                true
            }
            "card/readRFApdu" -> {
                readRFApdu(call, result)
                true
            }
            "card/stopAll" -> {
                stopAll(result)
                true
            }
            else -> false
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    private fun startSwipe(call: MethodCall, result: MethodChannel.Result) {
        val emv = DeviceServiceManager.getEmvL2()
        if (emv == null) {
            result.error("EMV_UNAVAILABLE", "EMV service unavailable", null)
            return
        }

        val timeout = call.argument<Int>("timeoutMs") ?: 60_000
        try {
            emv.checkCard(true, false, false, timeout, object : AidlCheckCardListener.Stub() {
                override fun onFindMagCard(trackData: TrackData?) {
                    val payload = mapOf(
                        "type" to "mag",
                        "track1" to (trackData?.firstTrackData ?: ""),
                        "track2" to (trackData?.secondTrackData ?: ""),
                        "track3" to (trackData?.thirdTrackData ?: ""),
                        "cardNo" to (trackData?.cardno ?: ""),
                        "expiryDate" to (trackData?.expiryDate ?: ""),
                        "serviceCode" to (trackData?.serviceCode ?: "")
                    )
                    eventSink?.success(payload)
                }

                override fun onFindICCard() {
                    eventSink?.success(mapOf("type" to "ic"))
                }

                override fun onFindRFCard() {
                    eventSink?.success(mapOf("type" to "rf"))
                }

                override fun onSwipeCardFail() {
                    eventSink?.success(mapOf("type" to "error", "message" to "Swipe failed"))
                }

                override fun onTimeout() {
                    eventSink?.success(mapOf("type" to "timeout"))
                }

                override fun onCanceled() {
                    eventSink?.success(mapOf("type" to "canceled"))
                }

                override fun onError(code: Int) {
                    eventSink?.success(mapOf("type" to "error", "code" to code))
                }
            })
            result.success(mapOf("started" to true))
        } catch (error: RemoteException) {
            result.error("SWIPE_EXCEPTION", error.message, null)
        }
    }

    private fun stopSwipe(result: MethodChannel.Result) {
        val emv = DeviceServiceManager.getEmvL2()
        if (emv == null) {
            result.success(mapOf("stopped" to true))
            return
        }
        runCatching { emv.cancelCheckCard() }
            .onSuccess { result.success(mapOf("stopped" to true)) }
            .onFailure { result.error("SWIPE_STOP_EXCEPTION", it.message, null) }
    }

    private fun startIC(result: MethodChannel.Result) {
        val ic = DeviceServiceManager.getICCardReader()
        if (ic == null) {
            result.error("IC_UNAVAILABLE", "IC card reader unavailable", null)
            return
        }
        runCatching { ic.open() }
            .onSuccess { opened -> result.success(mapOf("opened" to opened)) }
            .onFailure { result.error("IC_OPEN_EXCEPTION", it.message, null) }
    }

    private fun stopIC(result: MethodChannel.Result) {
        val ic = DeviceServiceManager.getICCardReader()
        if (ic == null) {
            result.success(mapOf("closed" to true))
            return
        }
        runCatching { ic.close() }
            .onSuccess { closed -> result.success(mapOf("closed" to closed)) }
            .onFailure { result.error("IC_CLOSE_EXCEPTION", it.message, null) }
    }

    private fun isICPresent(result: MethodChannel.Result) {
        val ic = DeviceServiceManager.getICCardReader()
        if (ic == null) {
            result.error("IC_UNAVAILABLE", "IC card reader unavailable", null)
            return
        }
        runCatching { ic.isExist() }
            .onSuccess { exists -> result.success(mapOf("present" to exists)) }
            .onFailure { result.error("IC_EXISTS_EXCEPTION", it.message, null) }
    }

    private fun resetIC(result: MethodChannel.Result) {
        val ic = DeviceServiceManager.getICCardReader()
        if (ic == null) {
            result.error("IC_UNAVAILABLE", "IC card reader unavailable", null)
            return
        }
        runCatching { ic.reset(0x00) }
            .onSuccess { data -> result.success(mapOf("atr" to bytesToHex(data))) }
            .onFailure { result.error("IC_RESET_EXCEPTION", it.message, null) }
    }

    private fun readICApdu(call: MethodCall, result: MethodChannel.Result) {
        val ic = DeviceServiceManager.getICCardReader()
        if (ic == null) {
            result.error("IC_UNAVAILABLE", "IC card reader unavailable", null)
            return
        }
        val apduHex = call.argument<String>("apduHex").orEmpty()
        val apdu = hexToBytes(apduHex)
        if (apdu == null) {
            result.error("BAD_APDU", "Invalid APDU hex", null)
            return
        }
        runCatching { ic.apduComm(apdu) }
            .onSuccess { data -> result.success(mapOf("responseHex" to bytesToHex(data))) }
            .onFailure { result.error("IC_APDU_EXCEPTION", it.message, null) }
    }

    private fun startRF(result: MethodChannel.Result) {
        val rf = DeviceServiceManager.getRFCardReader()
        if (rf == null) {
            result.error("RF_UNAVAILABLE", "RF card reader unavailable", null)
            return
        }
        runCatching { rf.open() }
            .onSuccess { opened -> result.success(mapOf("opened" to opened)) }
            .onFailure { result.error("RF_OPEN_EXCEPTION", it.message, null) }
    }

    private fun stopRF(result: MethodChannel.Result) {
        val rf = DeviceServiceManager.getRFCardReader()
        if (rf == null) {
            result.success(mapOf("closed" to true))
            return
        }
        runCatching { rf.close() }
            .onSuccess { closed -> result.success(mapOf("closed" to closed)) }
            .onFailure { result.error("RF_CLOSE_EXCEPTION", it.message, null) }
    }

    private fun pollRF(result: MethodChannel.Result) {
        val rf = DeviceServiceManager.getRFCardReader()
        if (rf == null) {
            result.error("RF_UNAVAILABLE", "RF card reader unavailable", null)
            return
        }

        runCatching {
            val present = rf.isExist()
            val cardType = if (present) rf.cardType else -1
            val uidHex = if (present) bytesToHex(rf.getUID()) else ""
            mapOf("present" to present, "cardType" to cardType, "uidHex" to uidHex)
        }.onSuccess { payload ->
            result.success(payload)
        }.onFailure {
            result.error("RF_POLL_EXCEPTION", it.message, null)
        }
    }

    private fun readRFApdu(call: MethodCall, result: MethodChannel.Result) {
        val rf = DeviceServiceManager.getRFCardReader()
        if (rf == null) {
            result.error("RF_UNAVAILABLE", "RF card reader unavailable", null)
            return
        }
        val apduHex = call.argument<String>("apduHex").orEmpty()
        val apdu = hexToBytes(apduHex)
        if (apdu == null) {
            result.error("BAD_APDU", "Invalid APDU hex", null)
            return
        }
        runCatching { rf.apduComm(apdu) }
            .onSuccess { data -> result.success(mapOf("responseHex" to bytesToHex(data))) }
            .onFailure { result.error("RF_APDU_EXCEPTION", it.message, null) }
    }

    private fun stopAll(result: MethodChannel.Result) {
        runCatching { DeviceServiceManager.getEmvL2()?.cancelCheckCard() }
        runCatching { DeviceServiceManager.getICCardReader()?.close() }
        runCatching { DeviceServiceManager.getRFCardReader()?.close() }
        result.success(mapOf("stopped" to true))
    }

    private fun bytesToHex(data: ByteArray?): String {
        if (data == null || data.isEmpty()) return ""
        val builder = StringBuilder(data.size * 2)
        for (value in data) {
            builder.append(String.format(Locale.US, "%02X", value))
        }
        return builder.toString()
    }

    private fun hexToBytes(hex: String): ByteArray? {
        val clean = hex.replace(" ", "").trim()
        if (clean.isEmpty() || clean.length % 2 != 0) return null
        return runCatching {
            ByteArray(clean.length / 2) { index ->
                clean.substring(index * 2, index * 2 + 2).toInt(16).toByte()
            }
        }.getOrNull()
    }
}

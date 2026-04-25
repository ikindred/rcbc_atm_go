package com.example.rcbc_atm_go.topwise

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.Build
import android.os.IBinder
import android.util.Log
import com.topwise.cloudpos.aidl.AidlDeviceService
import com.topwise.cloudpos.aidl.emv.level2.AidlEmvL2
import com.topwise.cloudpos.aidl.iccard.AidlICCard
import com.topwise.cloudpos.aidl.printer.AidlPrinter
import com.topwise.cloudpos.aidl.rfcard.AidlRFCard

object DeviceServiceManager {
    private const val TAG = "DeviceServiceManager"
    private const val DEVICE_SERVICE_PACKAGE_NAME = "com.android.topwise.topusdkservice"
    private const val DEVICE_SERVICE_CLASS_NAME =
        "com.android.topwise.topusdkservice.service.DeviceService"
    private const val ACTION_DEVICE_SERVICE = "topwise_cloudpos_device_service"

    private var appContext: Context? = null
    private var deviceService: AidlDeviceService? = null
    private var isBound = false

    fun init(context: Context) {
        appContext = context.applicationContext
    }

    fun bindDeviceService(): Boolean {
        val context = appContext ?: return false
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            return getDeviceService() != null
        }

        return try {
            val intent = Intent().apply {
                action = ACTION_DEVICE_SERVICE
                setClassName(DEVICE_SERVICE_PACKAGE_NAME, DEVICE_SERVICE_CLASS_NAME)
            }
            isBound = context.bindService(intent, connection, Context.BIND_AUTO_CREATE)
            isBound
        } catch (error: Exception) {
            Log.e(TAG, "bindDeviceService failed", error)
            false
        }
    }

    fun unBindDeviceService() {
        val context = appContext ?: return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            return
        }

        if (!isBound) return
        runCatching {
            context.unbindService(connection)
            isBound = false
            deviceService = null
        }.onFailure { error ->
            Log.w(TAG, "unBindDeviceService failed", error)
        }
    }

    fun getPrinter(): AidlPrinter? {
        val service = getDeviceService() ?: return null
        return runCatching { AidlPrinter.Stub.asInterface(service.printer) }.getOrNull()
    }

    fun getEmvL2(): AidlEmvL2? {
        val service = getDeviceService() ?: return null
        return runCatching { AidlEmvL2.Stub.asInterface(service.l2Emv) }.getOrNull()
    }

    fun getICCardReader(): AidlICCard? {
        val service = getDeviceService() ?: return null
        return runCatching { AidlICCard.Stub.asInterface(service.insertCardReader) }.getOrNull()
    }

    fun getRFCardReader(): AidlRFCard? {
        val service = getDeviceService() ?: return null
        return runCatching { AidlRFCard.Stub.asInterface(service.getRFIDReader()) }.getOrNull()
    }

    private fun getDeviceService(): AidlDeviceService? {
        if (deviceService != null) return deviceService
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return deviceService
        val binder = getSystemService(ACTION_DEVICE_SERVICE) ?: return null
        deviceService = AidlDeviceService.Stub.asInterface(binder)
        return deviceService
    }

    private val connection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            deviceService = AidlDeviceService.Stub.asInterface(service)
            Log.i(TAG, "Topwise service connected")
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            deviceService = null
            isBound = false
            Log.w(TAG, "Topwise service disconnected")
        }
    }

    private fun getSystemService(serviceName: String): IBinder? {
        return runCatching {
            val context = appContext ?: return null
            val loader = context.classLoader
            val serviceManager = loader.loadClass("android.os.ServiceManager")
            val getServiceMethod = serviceManager.getMethod("getService", String::class.java)
            getServiceMethod.invoke(serviceManager, serviceName) as? IBinder
        }.getOrNull()
    }
}

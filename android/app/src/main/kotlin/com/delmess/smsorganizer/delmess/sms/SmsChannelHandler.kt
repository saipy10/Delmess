package com.delmess.smsorganizer.delmess.sms

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class SmsChannelHandler : FlutterPlugin, MethodChannel.MethodCallHandler, EventChannel.StreamHandler,
    ActivityAware, PluginRegistry.RequestPermissionsResultListener {

    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var context: Context? = null
    private var activity: Activity? = null
    private var pendingResult: MethodChannel.Result? = null

    companion object {
        const val METHOD_CHANNEL_NAME = "com.delmess.smsorganizer/sms"
        const val EVENT_CHANNEL_NAME = "com.delmess.smsorganizer/sms_events"
        const val PERMISSION_REQUEST_CODE = 8801
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        methodChannel = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL_NAME)
        methodChannel?.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, EVENT_CHANNEL_NAME)
        eventChannel?.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel?.setMethodCallHandler(null)
        eventChannel?.setStreamHandler(null)
        methodChannel = null
        eventChannel = null
        context = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val currentContext = context ?: run {
            result.error("NO_CONTEXT", "Application context is not available", null)
            return
        }

        when (call.method) {
            "getPermissionState" -> {
                val state = checkPermissionState()
                result.success(state)
            }
            "requestPermissions" -> {
                val currentActivity = activity
                if (currentActivity == null) {
                    result.error("NO_ACTIVITY", "Cannot request permissions without active activity", null)
                    return
                }

                val hasRead = ContextCompat.checkSelfPermission(
                    currentContext,
                    Manifest.permission.READ_SMS
                ) == PackageManager.PERMISSION_GRANTED

                if (hasRead) {
                    result.success("granted")
                    return
                }

                pendingResult = result
                ActivityCompat.requestPermissions(
                    currentActivity,
                    arrayOf(
                        Manifest.permission.READ_SMS,
                        Manifest.permission.RECEIVE_SMS
                    ),
                    PERMISSION_REQUEST_CODE
                )
            }
            "openAppSettings" -> {
                try {
                    val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                        data = Uri.fromParts("package", currentContext.packageName, null)
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    currentContext.startActivity(intent)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("SETTINGS_ERROR", e.localizedMessage, null)
                }
            }
            "getSmsCount" -> {
                val count = SmsReader.getTotalSmsCount(currentContext)
                result.success(count)
            }
            "getSmsBatch" -> {
                val limit = call.argument<Int>("limit") ?: 100
                val offset = call.argument<Int>("offset") ?: 0
                val since = call.argument<Long>("since")
                val messages = SmsReader.getSmsBatch(currentContext, limit, offset, since)
                result.success(messages)
            }
            else -> result.notImplemented()
        }
    }

    private fun checkPermissionState(): String {
        val currentContext = context ?: return "unknown"
        val readGranted = ContextCompat.checkSelfPermission(
            currentContext,
            Manifest.permission.READ_SMS
        ) == PackageManager.PERMISSION_GRANTED

        if (readGranted) return "granted"

        val currentActivity = activity
        if (currentActivity != null) {
            val shouldShowRationale = ActivityCompat.shouldShowRequestPermissionRationale(
                currentActivity,
                Manifest.permission.READ_SMS
            )
            // If they previously denied and rationale is false, it could be permanently denied
            // We return "denied" or "permanentlyDenied"
            return if (shouldShowRationale) "denied" else "unknown"
        }

        return "denied"
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        if (requestCode == PERMISSION_REQUEST_CODE) {
            val readGranted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
            val state = if (readGranted) "granted" else "denied"
            pendingResult?.success(state)
            pendingResult = null
            return true
        }
        return false
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        SmsBroadcastReceiver.eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        SmsBroadcastReceiver.eventSink = null
    }
}

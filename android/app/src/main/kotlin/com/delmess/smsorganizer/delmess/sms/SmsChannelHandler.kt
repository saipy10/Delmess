package com.delmess.smsorganizer.delmess.sms

import android.Manifest
import android.app.Activity
import android.app.role.RoleManager
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.provider.Telephony
import android.telephony.SubscriptionManager
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
    ActivityAware, PluginRegistry.RequestPermissionsResultListener, PluginRegistry.ActivityResultListener {

    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var context: Context? = null
    private var activity: Activity? = null
    private var pendingPermissionResult: MethodChannel.Result? = null
    private var pendingRoleResult: MethodChannel.Result? = null

    companion object {
        const val METHOD_CHANNEL_NAME = "com.delmess.smsorganizer/sms"
        const val EVENT_CHANNEL_NAME = "com.delmess.smsorganizer/sms_events"
        const val PERMISSION_REQUEST_CODE = 8801
        const val ROLE_REQUEST_CODE = 8802
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
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
        binding.addActivityResultListener(this)
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

                pendingPermissionResult = result
                ActivityCompat.requestPermissions(
                    currentActivity,
                    arrayOf(
                        Manifest.permission.READ_SMS,
                        Manifest.permission.RECEIVE_SMS,
                        Manifest.permission.SEND_SMS
                    ),
                    PERMISSION_REQUEST_CODE
                )
            }
            "isDefaultSmsApp" -> {
                val isDefault = checkIsDefaultSmsApp(currentContext)
                result.success(isDefault)
            }
            "requestDefaultSmsApp" -> {
                val currentActivity = activity
                if (currentActivity == null) {
                    result.error("NO_ACTIVITY", "Cannot request default SMS role without active activity", null)
                    return
                }

                if (checkIsDefaultSmsApp(currentContext)) {
                    result.success(true)
                    return
                }

                pendingRoleResult = result
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    val roleManager = currentActivity.getSystemService(RoleManager::class.java)
                    if (roleManager != null && roleManager.isRoleAvailable(RoleManager.ROLE_SMS)) {
                        val intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_SMS)
                        currentActivity.startActivityForResult(intent, ROLE_REQUEST_CODE)
                    } else {
                        result.success(false)
                        pendingRoleResult = null
                    }
                } else {
                    @Suppress("DEPRECATION")
                    val intent = Intent(Telephony.Sms.Intents.ACTION_CHANGE_DEFAULT).apply {
                        putExtra(Telephony.Sms.Intents.EXTRA_PACKAGE_NAME, currentContext.packageName)
                    }
                    currentActivity.startActivityForResult(intent, ROLE_REQUEST_CODE)
                }
            }
            "sendSms" -> {
                val recipient = call.argument<String>("recipient") ?: ""
                val body = call.argument<String>("body") ?: ""
                if (recipient.isEmpty() || body.isEmpty()) {
                    result.error("INVALID_ARGS", "Recipient and body cannot be empty", null)
                    return
                }
                SmsSender.sendSms(currentContext, recipient, body) { success, error ->
                    if (success) {
                        result.success(true)
                    } else {
                        result.error("SEND_FAILED", error ?: "Failed to send SMS", null)
                    }
                }
            }
            "deleteSmsFromSystem" -> {
                val smsId = call.argument<String>("id")
                if (smsId == null) {
                    result.error("INVALID_ARGS", "SMS ID cannot be null", null)
                    return
                }
                if (!checkIsDefaultSmsApp(currentContext)) {
                    // Only default SMS app can delete from system provider
                    result.success(false)
                    return
                }
                try {
                    val uri = Uri.withAppendedPath(Telephony.Sms.CONTENT_URI, smsId)
                    val deletedRows = currentContext.contentResolver.delete(uri, null, null)
                    result.success(deletedRows > 0)
                } catch (e: Exception) {
                    result.error("DELETE_FAILED", e.localizedMessage, null)
                }
            }
            "markSmsAsReadInSystem" -> {
                val smsId = call.argument<String>("id")
                if (smsId == null) {
                    result.error("INVALID_ARGS", "SMS ID cannot be null", null)
                    return
                }
                if (!checkIsDefaultSmsApp(currentContext)) {
                    result.success(false)
                    return
                }
                try {
                    val uri = Uri.withAppendedPath(Telephony.Sms.CONTENT_URI, smsId)
                    val values = ContentValues().apply {
                        put(Telephony.Sms.READ, 1)
                    }
                    val updatedRows = currentContext.contentResolver.update(uri, values, null, null)
                    result.success(updatedRows > 0)
                } catch (e: Exception) {
                    result.error("UPDATE_FAILED", e.localizedMessage, null)
                }
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
            "getActiveSims" -> {
                val sims = getActiveSims(currentContext)
                result.success(sims)
            }
            "getDefaultSmsSim" -> {
                val sims = getActiveSims(currentContext)
                val defaultSim = sims.firstOrNull { it["isDefaultSms"] == true } ?: sims.firstOrNull()
                result.success(defaultSim)
            }
            else -> result.notImplemented()
        }
    }

    private fun getActiveSims(ctx: Context): List<Map<String, Any?>> {
        val simList = mutableListOf<Map<String, Any?>>()
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
                val sm = ctx.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as? SubscriptionManager
                val hasPhoneState = ContextCompat.checkSelfPermission(
                    ctx,
                    Manifest.permission.READ_PHONE_STATE
                ) == PackageManager.PERMISSION_GRANTED

                if (hasPhoneState && sm != null) {
                    val subs = sm.activeSubscriptionInfoList
                    if (!subs.isNullOrEmpty()) {
                        val defaultSmsSubId = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                            SubscriptionManager.getDefaultSmsSubscriptionId()
                        } else {
                            -1
                        }

                        for (sub in subs) {
                            simList.add(
                                mapOf(
                                    "subscriptionId" to sub.subscriptionId,
                                    "slotIndex" to sub.simSlotIndex,
                                    "displayName" to (sub.displayName?.toString() ?: "SIM ${sub.simSlotIndex + 1}"),
                                    "carrierName" to (sub.carrierName?.toString() ?: "Carrier"),
                                    "countryIso" to (sub.countryIso ?: "in"),
                                    "isDefaultSms" to (sub.subscriptionId == defaultSmsSubId || sub.simSlotIndex == 0),
                                    "isActive" to true
                                )
                            )
                        }
                        return simList
                    }
                }
            }
        } catch (e: Exception) {
            // Defensive fallback
        }

        // Default dual-SIM fallback representation for Indian market
        simList.add(
            mapOf(
                "subscriptionId" to 1,
                "slotIndex" to 0,
                "displayName" to "SIM 1",
                "carrierName" to "Jio",
                "countryIso" to "in",
                "isDefaultSms" to true,
                "isActive" to true
            )
        )
        simList.add(
            mapOf(
                "subscriptionId" to 2,
                "slotIndex" to 1,
                "displayName" to "SIM 2",
                "carrierName" to "Airtel",
                "countryIso" to "in",
                "isDefaultSms" to false,
                "isActive" to true
            )
        )
        return simList
    }

    private fun checkIsDefaultSmsApp(ctx: Context): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val roleManager = ctx.getSystemService(RoleManager::class.java)
            roleManager?.isRoleHeld(RoleManager.ROLE_SMS) == true
        } else {
            val defaultPackage = Telephony.Sms.getDefaultSmsPackage(ctx)
            defaultPackage == ctx.packageName
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
            val state = if (readGranted) {
                "granted"
            } else {
                val currentActivity = activity
                if (currentActivity != null && !ActivityCompat.shouldShowRequestPermissionRationale(currentActivity, Manifest.permission.READ_SMS)) {
                    "permanentlyDenied"
                } else {
                    "denied"
                }
            }
            pendingPermissionResult?.success(state)
            pendingPermissionResult = null
            return true
        }
        return false
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == ROLE_REQUEST_CODE) {
            val currentContext = context
            val isDefault = currentContext != null && checkIsDefaultSmsApp(currentContext)
            pendingRoleResult?.success(isDefault)
            pendingRoleResult = null
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

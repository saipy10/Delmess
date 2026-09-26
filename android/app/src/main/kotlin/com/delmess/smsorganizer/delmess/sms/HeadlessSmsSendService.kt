package com.delmess.smsorganizer.delmess.sms

import android.app.Service
import android.content.Intent
import android.net.Uri
import android.os.IBinder
import android.telephony.TelephonyManager

/**
 * Service required by Android OS to register as a Default SMS Application.
 * Handles quick text responses when declining an incoming phone call.
 */
class HeadlessSmsSendService : Service() {

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == TelephonyManager.ACTION_RESPOND_VIA_MESSAGE) {
            val extras = intent.extras
            val uri = intent.data
            if (extras != null && uri != null) {
                val message = extras.getString(Intent.EXTRA_TEXT)
                val recipient = getRecipientFromUri(uri)
                if (!recipient.isNullOrEmpty() && !message.isNullOrEmpty()) {
                    SmsSender.sendSms(this, recipient, message)
                }
            }
        }
        stopSelf(startId)
        return START_NOT_STICKY
    }

    private fun getRecipientFromUri(uri: Uri): String? {
        val schemeData = uri.schemeSpecificPart
        if (schemeData.isNullOrEmpty()) return null
        val index = schemeData.indexOf('?')
        return if (index != -1) {
            schemeData.substring(0, index)
        } else {
            schemeData
        }
    }
}

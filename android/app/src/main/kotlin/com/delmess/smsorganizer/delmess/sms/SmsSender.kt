package com.delmess.smsorganizer.delmess.sms

import android.app.PendingIntent
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Telephony
import android.telephony.SmsManager

object SmsSender {
    const val ACTION_SMS_SENT = "com.delmess.smsorganizer.SMS_SENT"
    const val ACTION_SMS_DELIVERED = "com.delmess.smsorganizer.SMS_DELIVERED"

    fun getSmsManager(context: Context): SmsManager {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            context.getSystemService(SmsManager::class.java)
        } else {
            @Suppress("DEPRECATION")
            SmsManager.getDefault()
        }
    }

    fun sendSms(
        context: Context,
        recipient: String,
        message: String,
        onComplete: ((Boolean, String?) -> Unit)? = null
    ) {
        try {
            val smsManager = getSmsManager(context)
            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }

            val sentIntent = PendingIntent.getBroadcast(
                context,
                0,
                Intent(ACTION_SMS_SENT),
                flags
            )
            val deliveryIntent = PendingIntent.getBroadcast(
                context,
                0,
                Intent(ACTION_SMS_DELIVERED),
                flags
            )

            val parts = smsManager.divideMessage(message)
            if (parts.size > 1) {
                val sentIntents = ArrayList<PendingIntent>().apply { repeat(parts.size) { add(sentIntent) } }
                val deliveryIntents = ArrayList<PendingIntent>().apply { repeat(parts.size) { add(deliveryIntent) } }
                smsManager.sendMultipartTextMessage(recipient, null, parts, sentIntents, deliveryIntents)
            } else {
                smsManager.sendTextMessage(recipient, null, message, sentIntent, deliveryIntent)
            }

            // If DelMess is default SMS app, write sent SMS to Telephony.Sms.Sent provider
            try {
                val values = ContentValues().apply {
                    put(Telephony.Sms.ADDRESS, recipient)
                    put(Telephony.Sms.BODY, message)
                    put(Telephony.Sms.DATE, System.currentTimeMillis())
                    put(Telephony.Sms.READ, 1)
                    put(Telephony.Sms.TYPE, Telephony.Sms.MESSAGE_TYPE_SENT)
                }
                context.contentResolver.insert(Telephony.Sms.Sent.CONTENT_URI, values)
            } catch (_: Exception) {
                // Ignore if not allowed
            }

            onComplete?.invoke(true, null)
        } catch (e: Exception) {
            onComplete?.invoke(false, e.localizedMessage)
        }
    }
}

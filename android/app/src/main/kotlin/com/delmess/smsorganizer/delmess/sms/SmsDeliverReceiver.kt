package com.delmess.smsorganizer.delmess.sms

import android.content.BroadcastReceiver
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.provider.Telephony

/**
 * BroadcastReceiver that receives incoming SMS when DelMess IS the default SMS app.
 * In accordance with Android Telephony specifications, the default SMS app must:
 * 1. Receive android.provider.Telephony.SMS_DELIVER
 * 2. Write the incoming SMS into the system Telephony provider (Telephony.Sms.Inbox)
 * 3. Notify the local app / UI (via eventSink to Flutter)
 */
class SmsDeliverReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Telephony.Sms.Intents.SMS_DELIVER_ACTION) {
            try {
                val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
                if (!messages.isNullOrEmpty()) {
                    val firstMessage = messages[0]
                    val sender = firstMessage.displayOriginatingAddress ?: firstMessage.originatingAddress ?: "Unknown"
                    val timestamp = firstMessage.timestampMillis

                    val bodyBuilder = StringBuilder()
                    for (sms in messages) {
                        bodyBuilder.append(sms.displayMessageBody ?: sms.messageBody ?: "")
                    }
                    val body = bodyBuilder.toString()
                    val id = "dlv_${timestamp}_${sender.hashCode()}"

                    // 1. Write to Android system Telephony.Sms.Inbox (Allowed only for default SMS handler)
                    try {
                        val values = ContentValues().apply {
                            put(Telephony.Sms.ADDRESS, sender)
                            put(Telephony.Sms.BODY, body)
                            put(Telephony.Sms.DATE, timestamp)
                            put(Telephony.Sms.READ, 0)
                            put(Telephony.Sms.SEEN, 0)
                            put(Telephony.Sms.TYPE, Telephony.Sms.MESSAGE_TYPE_INBOX)
                        }
                        context.contentResolver.insert(Telephony.Sms.Inbox.CONTENT_URI, values)
                    } catch (e: Exception) {
                        // In case of any provider write failure, do not abort
                    }

                    // 2. Deliver to Flutter event sink for instant reactive inbox update
                    val messageMap = mapOf<String, Any?>(
                        "id" to id,
                        "threadId" to id,
                        "sender" to sender,
                        "body" to body,
                        "receivedAt" to timestamp,
                        "isRead" to false
                    )

                    SmsBroadcastReceiver.eventSink?.success(messageMap)
                }
            } catch (e: Exception) {
                // Defensive catch to prevent crashes
            }
        }
    }
}

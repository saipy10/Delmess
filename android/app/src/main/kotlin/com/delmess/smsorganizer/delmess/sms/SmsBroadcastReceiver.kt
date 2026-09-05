package com.delmess.smsorganizer.delmess.sms

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import io.flutter.plugin.common.EventChannel

class SmsBroadcastReceiver : BroadcastReceiver() {
    companion object {
        var eventSink: EventChannel.EventSink? = null
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
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
                    val id = "rcv_${timestamp}_${sender.hashCode()}"

                    val messageMap = mapOf<String, Any?>(
                        "id" to id,
                        "threadId" to id,
                        "sender" to sender,
                        "body" to body,
                        "receivedAt" to timestamp,
                        "isRead" to false
                    )

                    eventSink?.success(messageMap)
                }
            } catch (e: Exception) {
                // Defensive catch to prevent crashes
            }
        }
    }
}

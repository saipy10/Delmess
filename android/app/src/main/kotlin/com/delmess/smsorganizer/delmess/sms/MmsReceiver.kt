package com.delmess.smsorganizer.delmess.sms

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony

/**
 * BroadcastReceiver required by Android OS to register as a Default SMS Application.
 * Handles incoming MMS WAP PUSH notifications.
 */
class MmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Telephony.Sms.Intents.WAP_PUSH_DELIVER_ACTION) {
            // DelMess is an SMS text organizer; MMS raw push events are acknowledged safely.
        }
    }
}

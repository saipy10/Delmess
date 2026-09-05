package com.delmess.smsorganizer.delmess.sms

import android.content.Context
import android.database.Cursor
import android.net.Uri
import android.provider.Telephony

object SmsReader {
    private val SMS_URI: Uri = Telephony.Sms.CONTENT_URI

    private val PROJECTION = arrayOf(
        Telephony.Sms._ID,
        Telephony.Sms.THREAD_ID,
        Telephony.Sms.ADDRESS,
        Telephony.Sms.BODY,
        Telephony.Sms.DATE,
        Telephony.Sms.READ
    )

    fun getTotalSmsCount(context: Context): Int {
        var cursor: Cursor? = null
        try {
            cursor = context.contentResolver.query(
                SMS_URI,
                arrayOf("COUNT(*)"),
                null,
                null,
                null
            )
            if (cursor != null && cursor.moveToFirst()) {
                return cursor.getInt(0)
            }
        } catch (e: Exception) {
            // Safe fallback without logging sensitive data
        } finally {
            cursor?.close()
        }
        return 0
    }

    fun getSmsBatch(
        context: Context,
        limit: Int,
        offset: Int,
        sinceMillis: Long? = null
    ): List<Map<String, Any?>> {
        val messages = mutableListOf<Map<String, Any?>>()
        var cursor: Cursor? = null

        val selection: String?
        val selectionArgs: Array<String>?
        if (sinceMillis != null && sinceMillis > 0) {
            selection = "${Telephony.Sms.DATE} > ?"
            selectionArgs = arrayOf(sinceMillis.toString())
        } else {
            selection = null
            selectionArgs = null
        }

        val sortOrder = "${Telephony.Sms.DATE} DESC LIMIT $limit OFFSET $offset"

        try {
            cursor = context.contentResolver.query(
                SMS_URI,
                PROJECTION,
                selection,
                selectionArgs,
                sortOrder
            )

            if (cursor != null) {
                val idIndex = cursor.getColumnIndex(Telephony.Sms._ID)
                val threadIdIndex = cursor.getColumnIndex(Telephony.Sms.THREAD_ID)
                val addressIndex = cursor.getColumnIndex(Telephony.Sms.ADDRESS)
                val bodyIndex = cursor.getColumnIndex(Telephony.Sms.BODY)
                val dateIndex = cursor.getColumnIndex(Telephony.Sms.DATE)
                val readIndex = cursor.getColumnIndex(Telephony.Sms.READ)

                while (cursor.moveToNext()) {
                    val id = if (idIndex != -1) cursor.getString(idIndex) ?: "" else ""
                    val threadId = if (threadIdIndex != -1) cursor.getString(threadIdIndex) ?: id else id
                    val address = if (addressIndex != -1) cursor.getString(addressIndex) ?: "Unknown" else "Unknown"
                    val body = if (bodyIndex != -1) cursor.getString(bodyIndex) ?: "" else ""
                    val date = if (dateIndex != -1) cursor.getLong(dateIndex) else System.currentTimeMillis()
                    val read = if (readIndex != -1) cursor.getInt(readIndex) == 1 else false

                    val item = mapOf<String, Any?>(
                        "id" to id,
                        "threadId" to threadId,
                        "sender" to address,
                        "body" to body,
                        "receivedAt" to date,
                        "isRead" to read
                    )
                    messages.add(item)
                }
            }
        } catch (e: Exception) {
            // Defensive handling
        } finally {
            cursor?.close()
        }

        return messages
    }
}

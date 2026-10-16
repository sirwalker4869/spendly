package com.example.spendly // Sesuaikan package name

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

class SpendlyNotificationService : NotificationListenerService() {
    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        
        val packageName = sbn?.packageName ?: return
        val extras = sbn.notification.extras
        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString() ?: ""
        val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: ""

        // Filter hanya membaca dari aplikasi DANA (id.dana) atau BCA (com.bca)
        if (packageName == "id.dana" || packageName == "com.bca") {
            MainActivity.instance?.sendNotificationToFlutter(title, text, packageName)
        }
    }
}
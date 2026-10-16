package com.example.spendly // Sesuaikan dengan package name project kamu

import android.content.Intent
import android.os.Bundle
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity: FlutterActivity(), EventChannel.StreamHandler {
    private val CHANNEL = "com.spendly.app/notifications"
    private var eventSink: EventChannel.EventSink? = null

    companion object {
        var instance: MainActivity? = null
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        instance = this
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setStreamHandler(this)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun sendNotificationToFlutter(title: String, text: String, pkg: String) {
        // Kirim data notifikasi ke Dart/Flutter secara real-time
        val data = mapOf("title" to title, "content" to text, "packageName" to pkg)
        runOnUiThread {
            eventSink?.success(data)
        }
    }
}
package com.myspace.app

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.myspace.app/widget_events"
    private var methodChannel: MethodChannel? = null
    private var pendingWidgetLaunch: Uri? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)

        pendingWidgetLaunch?.let {
            dispatchWidgetLaunch(it)
            pendingWidgetLaunch = null
        }
    }

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        handleWidgetIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleWidgetIntent(intent)
    }

    private fun handleWidgetIntent(intent: Intent?) {
        val data = intent?.data ?: return

        if (data.scheme == "myspace" && data.host == "widget") {
            if (methodChannel != null) {
                dispatchWidgetLaunch(data)
            } else {
                pendingWidgetLaunch = data
            }
        }
    }

    private fun dispatchWidgetLaunch(data: Uri) {
        methodChannel?.invokeMethod(
            "widgetClicked",
            mapOf("uri" to data.toString())
        )
    }
}

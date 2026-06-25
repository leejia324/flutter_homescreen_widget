package com.yourpackage // TODO: replace with your package name

import android.content.Intent
import android.os.Bundle
import com.leejia.flutter_homescreen_widget.FlutterHomescreenWidgetPlugin
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleWidgetAction(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleWidgetAction(intent)
    }

    private fun handleWidgetAction(intent: Intent?) {
        val actionId = intent?.getStringExtra("actionId") ?: return
        FlutterHomescreenWidgetPlugin.sendAction(actionId)
    }
}

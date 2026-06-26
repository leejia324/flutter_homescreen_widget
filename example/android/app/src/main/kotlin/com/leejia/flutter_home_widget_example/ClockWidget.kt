package com.leejia.flutter_home_widget_example

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import androidx.compose.runtime.Composable
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.provideContent
import androidx.glance.layout.Box
import androidx.glance.layout.fillMaxSize
import androidx.glance.text.Text
import java.io.File

private const val PREFS_NAME = "flutter_homescreen_widget"

class ClockWidget : GlanceAppWidget() {
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val imagePath = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getString("ClockWidget_image_path", null)
        provideContent { WidgetContent(imagePath) }
    }
}

class ClockWidgetSmall : GlanceAppWidget() {
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val imagePath = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getString("ClockWidgetSmall_image_path", null)
        provideContent { WidgetContent(imagePath) }
    }
}

@Composable
private fun WidgetContent(imagePath: String?) {
    Box(modifier = GlanceModifier.fillMaxSize()) {
        if (imagePath != null && File(imagePath).exists()) {
            val bitmap = BitmapFactory.decodeFile(imagePath)
            Image(
                provider = ImageProvider(bitmap),
                contentDescription = null,
                modifier = GlanceModifier.fillMaxSize(),
            )
        } else {
            Text("Open the app to update the widget")
        }
    }
}

class ClockWidgetWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = ClockWidget()

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
    }
}

class ClockWidgetSmallWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = ClockWidgetSmall()

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
    }
}

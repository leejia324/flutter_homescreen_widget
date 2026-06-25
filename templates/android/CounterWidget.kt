package com.yourpackage // TODO: replace with your package name

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import androidx.compose.runtime.Composable
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.action.actionStartActivity
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.provideContent
import androidx.glance.layout.Box
import androidx.glance.layout.fillMaxSize
import androidx.glance.text.Text
import com.leejia.flutter_homescreen_widget.FlutterHomescreenWidgetPlugin
import org.json.JSONArray
import java.io.File

// Must match the widgetName passed to FlutterHomescreenWidget.update(widgetName: ...)
private const val WIDGET_NAME = "CounterWidget"
private const val PREFS_NAME  = "flutter_homescreen_widget"

data class WidgetAction(
    val id: String,
    val left: Float,
    val top: Float,
    val width: Float,
    val height: Float,
)

class CounterWidget : GlanceAppWidget() {

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val imagePath = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getString("${WIDGET_NAME}_image_path", null)

        val actionsJson = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getString("${WIDGET_NAME}_actions", "[]")

        val actions = parseActions(actionsJson ?: "[]")

        provideContent {
            CounterWidgetContent(context = context, imagePath = imagePath, actions = actions)
        }
    }

    private fun parseActions(json: String): List<WidgetAction> {
        return try {
            val array = JSONArray(json)
            (0 until array.length()).map { i ->
                val obj = array.getJSONObject(i)
                WidgetAction(
                    id     = obj.getString("id"),
                    left   = obj.getDouble("left").toFloat(),
                    top    = obj.getDouble("top").toFloat(),
                    width  = obj.getDouble("width").toFloat(),
                    height = obj.getDouble("height").toFloat(),
                )
            }
        } catch (e: Exception) {
            emptyList()
        }
    }
}

@Composable
private fun CounterWidgetContent(
    context: Context,
    imagePath: String?,
    actions: List<WidgetAction>,
) {
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

        actions.forEach { action ->
            Box(
                modifier = GlanceModifier
                    .fillMaxSize()
                    .clickable(
                        onClick = actionStartActivity<MainActivity>(
                            parameters = androidx.glance.action.ActionParameters.Builder()
                                .set(
                                    androidx.glance.action.ActionParameters.Key<String>("actionId"),
                                    action.id
                                )
                                .build()
                        )
                    )
            ) {}
        }
    }
}

class CounterWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = CounterWidget()

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE) {
            goAsync()
        }
    }
}

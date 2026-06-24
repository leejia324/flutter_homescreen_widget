package com.leejia.flutter_widget_kit

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import java.io.File

/**
 * Android platform implementation of flutter_widget_kit.
 *
 * Bridges Dart calls to the native AppWidget system:
 * - [updateWidget]: saves PNG + action JSON, then broadcasts an update.
 * - [reloadWidget]: broadcasts an update without changing stored data.
 * - [onAction]: EventChannel stream that emits action IDs from widget taps.
 */
class FlutterWidgetKitPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var context: Context
    private var eventSink: EventChannel.EventSink? = null

    companion object {
        /** SharedPreferences file name used to share data with the widget process. */
        const val PREFS_NAME = "flutter_widget_kit"

        /** Singleton reference used by [MainActivity] to forward tap actions. */
        var instance: FlutterWidgetKitPlugin? = null

        /**
         * Forwards a widget tap action to Dart via the EventChannel.
         *
         * Call this from [MainActivity.handleWidgetAction] after reading the
         * `actionId` extra from the launch [Intent].
         */
        fun sendAction(actionId: String) {
            instance?.eventSink?.success(actionId)
        }
    }

    // MARK: - FlutterPlugin

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        instance = this

        methodChannel = MethodChannel(binding.binaryMessenger, "flutter_widget_kit")
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, "flutter_widget_kit/actions")
        eventChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        instance = null
    }

    // MARK: - MethodChannel.MethodCallHandler

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "updateWidget" -> updateWidget(call, result)
            "reloadWidget" -> reloadWidget(call, result)
            else           -> result.notImplemented()
        }
    }

    /**
     * Saves the rendered PNG to internal storage and action JSON to
     * [SharedPreferences], then broadcasts an AppWidget update.
     */
    private fun updateWidget(call: MethodCall, result: MethodChannel.Result) {
        val widgetName = call.argument<String>("widgetName") ?: return result.error(
            "INVALID_ARGS", "widgetName is required.", null
        )
        val imageBytes = call.argument<ByteArray>("imageBytes") ?: return result.error(
            "INVALID_ARGS", "imageBytes is required.", null
        )
        val actions = call.argument<List<Map<String, Any>>>("actions") ?: emptyList()

        // Persist the PNG in app-internal storage
        val imageFile = File(context.filesDir, "$widgetName.png")
        imageFile.writeBytes(imageBytes)

        // Persist action regions in SharedPreferences
        val prefs: SharedPreferences =
            context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val actionsJson = JSONArray(actions.map { JSONObject(it) })
        prefs.edit()
            .putString("${widgetName}_image_path", imageFile.absolutePath)
            .putString("${widgetName}_actions", actionsJson.toString())
            .apply()

        refreshWidgets(widgetName)
        result.success(null)
    }

    /** Triggers a widget refresh without changing stored image or actions. */
    private fun reloadWidget(call: MethodCall, result: MethodChannel.Result) {
        val widgetName = call.argument<String>("widgetName") ?: return result.error(
            "INVALID_ARGS", "widgetName is required.", null
        )
        refreshWidgets(widgetName)
        result.success(null)
    }

    /**
     * Sends an [AppWidgetManager.ACTION_APPWIDGET_UPDATE] broadcast to the
     * receiver class named `<packageName>.<widgetName>WidgetReceiver`.
     */
    private fun refreshWidgets(widgetName: String) {
        try {
            val receiverClass = Class.forName("${context.packageName}.${widgetName}WidgetReceiver")
            val intent = Intent(context, receiverClass).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                putExtra(
                    AppWidgetManager.EXTRA_APPWIDGET_IDS,
                    AppWidgetManager.getInstance(context)
                        .getAppWidgetIds(ComponentName(context, receiverClass))
                )
            }
            context.sendBroadcast(intent)
        } catch (e: ClassNotFoundException) {
            // Receiver not registered — widget may not be added to the home screen yet.
        }
    }

    // MARK: - EventChannel.StreamHandler

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}

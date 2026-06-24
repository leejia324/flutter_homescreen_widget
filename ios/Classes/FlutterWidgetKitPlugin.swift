import Flutter
import UIKit
import WidgetKit

/// The iOS platform implementation of flutter_widget_kit.
///
/// Handles method calls from Dart via `flutter_widget_kit` MethodChannel,
/// emits widget tap actions via `flutter_widget_kit/actions` EventChannel,
/// and receives deep links from the widget URL scheme `flutterhomewidget://`.
public class FlutterWidgetKitPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

    private var eventSink: FlutterEventSink?

    // MARK: - Registration

    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(
            name: "flutter_widget_kit",
            binaryMessenger: registrar.messenger()
        )
        let eventChannel = FlutterEventChannel(
            name: "flutter_widget_kit/actions",
            binaryMessenger: registrar.messenger()
        )

        let instance = FlutterWidgetKitPlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        registrar.addApplicationDelegate(instance)
        eventChannel.setStreamHandler(instance)
    }

    // MARK: - MethodChannel

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Arguments missing or wrong type.", details: nil))
            return
        }

        switch call.method {
        case "updateWidget":
            updateWidget(args: args, result: result)
        case "reloadWidget":
            reloadWidget(args: args, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /// Saves the rendered PNG and action JSON to the App Group container,
    /// then asks WidgetKit to reload the widget's timeline.
    private func updateWidget(args: [String: Any], result: @escaping FlutterResult) {
        guard
            let widgetName = args["widgetName"] as? String,
            let imageBytes = args["imageBytes"] as? FlutterStandardTypedData,
            let actions = args["actions"] as? [[String: Any]]
        else {
            result(FlutterError(code: "INVALID_ARGS", message: "widgetName, imageBytes, and actions are required.", details: nil))
            return
        }

        guard let appGroupId = appGroupIdentifier() else {
            result(FlutterError(
                code: "NO_APP_GROUP",
                message: "FlutterWidgetKitAppGroup is not set in Info.plist. See the setup guide.",
                details: nil
            ))
            return
        }

        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupId
        ) else {
            result(FlutterError(code: "CONTAINER_ERROR", message: "Cannot access App Group container.", details: nil))
            return
        }

        // Write rendered PNG to shared container
        let imageURL = containerURL.appendingPathComponent("\(widgetName).png")
        do {
            try imageBytes.data.write(to: imageURL)
        } catch {
            result(FlutterError(code: "WRITE_ERROR", message: error.localizedDescription, details: nil))
            return
        }

        // Write action JSON to shared container
        let actionsURL = containerURL.appendingPathComponent("\(widgetName)_actions.json")
        if let actionsData = try? JSONSerialization.data(withJSONObject: actions) {
            try? actionsData.write(to: actionsURL)
        }

        // Ask WidgetKit to reload the timeline for this widget kind
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadTimelines(ofKind: widgetName)
        }

        result(nil)
    }

    /// Asks WidgetKit to reload the widget timeline without updating the image.
    private func reloadWidget(args: [String: Any], result: @escaping FlutterResult) {
        guard let widgetName = args["widgetName"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "widgetName is required.", details: nil))
            return
        }

        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadTimelines(ofKind: widgetName)
        }
        result(nil)
    }

    // MARK: - Deep link handling (widget tap → app)

    /// Handles `flutterhomewidget://action/<id>` URLs opened by widget taps.
    public func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        return handleWidgetURL(url)
    }

    public func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else { return false }
        return handleWidgetURL(url)
    }

    @discardableResult
    private func handleWidgetURL(_ url: URL) -> Bool {
        guard url.scheme == "flutterhomewidget",
              url.host == "action",
              let actionId = url.pathComponents.dropFirst().first
        else { return false }

        eventSink?(actionId)
        return true
    }

    // MARK: - EventChannel (FlutterStreamHandler)

    public func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }

    // MARK: - Helpers

    /// Reads the App Group identifier from the host app's Info.plist.
    private func appGroupIdentifier() -> String? {
        Bundle.main.object(forInfoDictionaryKey: "FlutterWidgetKitAppGroup") as? String
    }
}

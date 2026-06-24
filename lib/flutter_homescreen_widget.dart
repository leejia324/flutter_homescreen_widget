/// A Flutter plugin for updating iOS WidgetKit and Android Glance home screen
/// widgets using Flutter widgets as the UI.
///
/// ## Quick start
///
/// ```dart
/// final _navKey = GlobalKey<NavigatorState>();
///
/// void main() {
///   FlutterHomescreenWidget.init(_navKey);
///   runApp(MaterialApp(navigatorKey: _navKey, home: MyHome()));
/// }
/// ```
///
/// Then update a widget:
///
/// ```dart
/// await FlutterHomescreenWidget.update(
///   widgetName: 'MyWidget',
///   size: const Size(329, 155),
///   content: MyWidgetUI(data: data),
///   actions: [
///     WidgetAction(id: 'tap', area: const Rect.fromLTWH(0, 0, 1, 1)),
///   ],
/// );
/// ```
library;

import 'dart:async';

import 'package:flutter/widgets.dart';

import 'flutter_homescreen_widget_platform_interface.dart';
import 'src/widget_action.dart';
import 'src/widget_renderer.dart';

export 'src/widget_action.dart';

/// Entry point for the flutter_homescreen_widget plugin.
///
/// All methods are static. Call [init] once at app startup, then use
/// [update], [reload], and [onAction] anywhere in your app.
class FlutterHomescreenWidget {
  FlutterHomescreenWidget._();

  /// Registers the app's [NavigatorState] key.
  ///
  /// Must be called **before** [runApp] so the widget renderer can access
  /// the [Overlay] for off-screen rendering.
  ///
  /// ```dart
  /// final _navKey = GlobalKey<NavigatorState>();
  ///
  /// void main() {
  ///   FlutterHomescreenWidget.init(_navKey);
  ///   runApp(MaterialApp(navigatorKey: _navKey, home: MyHome()));
  /// }
  /// ```
  static void init(GlobalKey<NavigatorState> navigatorKey) {
    WidgetRenderer.init(navigatorKey);
  }

  /// Renders [content] to a PNG and pushes it to the native home screen widget.
  ///
  /// - [widgetName] must match the `kind` string used in the native widget
  ///   template (e.g. `"CounterWidget"`).
  /// - [size] is the logical size in dp/pt at which to render [content].
  ///   Use the standard sizes for each widget family:
  ///   - Small  → `Size(155, 155)`
  ///   - Medium → `Size(329, 155)`
  ///   - Large  → `Size(329, 345)`
  /// - [actions] defines tappable areas. Each area maps to an [id] that
  ///   [onAction] will emit when the user taps it.
  /// - [pixelRatio] controls output resolution (default 3.0 for @3x assets).
  ///
  /// ```dart
  /// await FlutterHomescreenWidget.update(
  ///   widgetName: 'CounterWidget',
  ///   size: const Size(329, 155),
  ///   content: CounterUI(count: 5),
  ///   actions: [
  ///     WidgetAction(id: 'increment', area: const Rect.fromLTWH(0.6, 0, 0.4, 0.5)),
  ///     WidgetAction(id: 'decrement', area: const Rect.fromLTWH(0.6, 0.5, 0.4, 0.5)),
  ///   ],
  /// );
  /// ```
  static Future<void> update({
    required String widgetName,
    required Widget content,
    required Size size,
    List<WidgetAction> actions = const [],
    double pixelRatio = 3.0,
  }) async {
    final bytes = await WidgetRenderer.render(
      widget: content,
      size: size,
      pixelRatio: pixelRatio,
    );

    await FlutterHomescreenWidgetPlatform.instance.updateWidget(
      widgetName: widgetName,
      imageBytes: bytes,
      actions: actions.map((a) => a.toMap()).toList(),
    );
  }

  /// Triggers a timeline reload on the native widget without re-rendering.
  ///
  /// Use this when the widget image is still valid but you want the OS to
  /// refresh the widget display (e.g. after the device wakes up).
  static Future<void> reload({required String widgetName}) {
    return FlutterHomescreenWidgetPlatform.instance.reloadWidget(
      widgetName: widgetName,
    );
  }

  /// A broadcast stream that emits the [WidgetAction.id] whenever the user
  /// taps a registered action area on a home screen widget.
  ///
  /// The app is brought to the foreground before the event is delivered.
  ///
  /// ```dart
  /// FlutterHomescreenWidget.onAction.listen((id) {
  ///   if (id == 'increment') setState(() => count++);
  /// });
  /// ```
  static Stream<String> get onAction {
    return FlutterHomescreenWidgetPlatform.instance.onAction;
  }
}

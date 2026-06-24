import 'dart:async';
import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_homescreen_widget_method_channel.dart';

/// The platform interface contract for [FlutterHomescreenWidget].
///
/// Platform implementations must extend this class and set [instance] to
/// themselves before any plugin methods are called.
abstract class FlutterHomescreenWidgetPlatform extends PlatformInterface {
  /// Constructs a [FlutterHomescreenWidgetPlatform].
  FlutterHomescreenWidgetPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterHomescreenWidgetPlatform _instance = MethodChannelFlutterHomescreenWidget();

  /// The current default [FlutterHomescreenWidgetPlatform] instance.
  ///
  /// Defaults to [MethodChannelFlutterHomescreenWidget].
  static FlutterHomescreenWidgetPlatform get instance => _instance;

  /// Sets the default [FlutterHomescreenWidgetPlatform] instance.
  static set instance(FlutterHomescreenWidgetPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Saves [imageBytes] and [actions] to shared storage, then triggers a
  /// native widget timeline reload for [widgetName].
  Future<void> updateWidget({
    required String widgetName,
    required Uint8List imageBytes,
    required List<Map<String, dynamic>> actions,
  }) {
    throw UnimplementedError('updateWidget() has not been implemented.');
  }

  /// Triggers a timeline reload for [widgetName] without updating the image.
  Future<void> reloadWidget({required String widgetName}) {
    throw UnimplementedError('reloadWidget() has not been implemented.');
  }

  /// A stream that emits action IDs when the user taps a widget area.
  Stream<String> get onAction {
    throw UnimplementedError('onAction has not been implemented.');
  }
}

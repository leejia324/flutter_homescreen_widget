import 'dart:async';
import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_widget_kit_method_channel.dart';

/// The platform interface contract for [FlutterWidgetKit].
///
/// Platform implementations must extend this class and set [instance] to
/// themselves before any plugin methods are called.
abstract class FlutterWidgetKitPlatform extends PlatformInterface {
  /// Constructs a [FlutterWidgetKitPlatform].
  FlutterWidgetKitPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterWidgetKitPlatform _instance = MethodChannelFlutterWidgetKit();

  /// The current default [FlutterWidgetKitPlatform] instance.
  ///
  /// Defaults to [MethodChannelFlutterWidgetKit].
  static FlutterWidgetKitPlatform get instance => _instance;

  /// Sets the default [FlutterWidgetKitPlatform] instance.
  static set instance(FlutterWidgetKitPlatform instance) {
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

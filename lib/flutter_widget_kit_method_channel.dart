import 'dart:async';

import 'package:flutter/services.dart';

import 'flutter_widget_kit_platform_interface.dart';

/// The default [FlutterWidgetKitPlatform] implementation using [MethodChannel]
/// and [EventChannel].
class MethodChannelFlutterWidgetKit extends FlutterWidgetKitPlatform {
  /// The method channel used to invoke native methods.
  final _methodChannel = const MethodChannel('flutter_widget_kit');

  /// The event channel used to receive tap-action events from native widgets.
  final _eventChannel = const EventChannel('flutter_widget_kit/actions');

  Stream<String>? _onActionStream;

  @override
  Future<void> updateWidget({
    required String widgetName,
    required Uint8List imageBytes,
    required List<Map<String, dynamic>> actions,
  }) async {
    await _methodChannel.invokeMethod<void>('updateWidget', {
      'widgetName': widgetName,
      'imageBytes': imageBytes,
      'actions': actions,
    });
  }

  @override
  Future<void> reloadWidget({required String widgetName}) async {
    await _methodChannel.invokeMethod<void>('reloadWidget', {
      'widgetName': widgetName,
    });
  }

  @override
  Stream<String> get onAction {
    _onActionStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) => event as String);
    return _onActionStream!;
  }
}

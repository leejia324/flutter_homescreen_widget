import 'dart:async';

import 'package:flutter/services.dart';

import 'flutter_homescreen_widget_platform_interface.dart';

/// The default [FlutterHomescreenWidgetPlatform] implementation using [MethodChannel]
/// and [EventChannel].
class MethodChannelFlutterHomescreenWidget extends FlutterHomescreenWidgetPlatform {
  /// The method channel used to invoke native methods.
  final _methodChannel = const MethodChannel('flutter_homescreen_widget');

  /// The event channel used to receive tap-action events from native widgets.
  final _eventChannel = const EventChannel('flutter_homescreen_widget/actions');

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

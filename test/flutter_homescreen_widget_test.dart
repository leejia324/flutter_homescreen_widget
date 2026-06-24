import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_homescreen_widget/flutter_homescreen_widget_platform_interface.dart';
import 'package:flutter_homescreen_widget/flutter_homescreen_widget_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterHomescreenWidgetPlatform
    with MockPlatformInterfaceMixin
    implements FlutterHomescreenWidgetPlatform {
  String? lastWidgetName;
  List<Map<String, dynamic>>? lastActions;
  String? reloadedWidgetName;
  final _actionController = StreamController<String>.broadcast();

  @override
  Future<void> updateWidget({
    required String widgetName,
    required Uint8List imageBytes,
    required List<Map<String, dynamic>> actions,
  }) async {
    lastWidgetName = widgetName;
    lastActions = actions;
  }

  @override
  Future<void> reloadWidget({required String widgetName}) async {
    reloadedWidgetName = widgetName;
  }

  @override
  Stream<String> get onAction => _actionController.stream;

  void emitAction(String id) => _actionController.add(id);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('MethodChannelFlutterHomescreenWidget is the default instance', () {
    expect(
      FlutterHomescreenWidgetPlatform.instance,
      isInstanceOf<MethodChannelFlutterHomescreenWidget>(),
    );
  });

  group('MockPlatform', () {
    late MockFlutterHomescreenWidgetPlatform mock;

    setUp(() {
      mock = MockFlutterHomescreenWidgetPlatform();
      FlutterHomescreenWidgetPlatform.instance = mock;
    });

    test('updateWidget stores widgetName and actions', () async {
      await mock.updateWidget(
        widgetName: 'TestWidget',
        imageBytes: Uint8List(0),
        actions: [
          {'id': 'tap', 'left': 0.0, 'top': 0.0, 'width': 1.0, 'height': 1.0},
        ],
      );
      expect(mock.lastWidgetName, 'TestWidget');
      expect(mock.lastActions?.first['id'], 'tap');
    });

    test('reloadWidget stores widgetName', () async {
      await mock.reloadWidget(widgetName: 'TestWidget');
      expect(mock.reloadedWidgetName, 'TestWidget');
    });

    test('onAction stream emits action ids', () async {
      final received = <String>[];
      final sub = mock.onAction.listen(received.add);
      mock.emitAction('increment');
      mock.emitAction('decrement');
      await Future.delayed(Duration.zero);
      expect(received, ['increment', 'decrement']);
      await sub.cancel();
    });
  });
}

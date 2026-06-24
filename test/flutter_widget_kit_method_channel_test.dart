import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_widget_kit/flutter_widget_kit_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MethodChannelFlutterWidgetKit platform;
  const channel = MethodChannel('flutter_widget_kit');
  final calls = <MethodCall>[];

  setUp(() {
    platform = MethodChannelFlutterWidgetKit();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
  });

  tearDown(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('updateWidget invokes correct method with expected arguments', () async {
    final bytes = Uint8List.fromList([1, 2, 3]);
    final actions = [
      {'id': 'tap', 'left': 0.0, 'top': 0.0, 'width': 1.0, 'height': 1.0},
    ];

    await platform.updateWidget(
      widgetName: 'MyWidget',
      imageBytes: bytes,
      actions: actions,
    );

    expect(calls.length, 1);
    expect(calls.first.method, 'updateWidget');
    expect(calls.first.arguments['widgetName'], 'MyWidget');
    expect(calls.first.arguments['actions'], actions);
  });

  test('reloadWidget invokes correct method with expected arguments', () async {
    await platform.reloadWidget(widgetName: 'MyWidget');

    expect(calls.length, 1);
    expect(calls.first.method, 'reloadWidget');
    expect(calls.first.arguments['widgetName'], 'MyWidget');
  });
}

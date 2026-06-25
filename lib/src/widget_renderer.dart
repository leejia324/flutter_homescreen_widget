import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Renders a Flutter widget tree to a PNG [Uint8List].
///
/// Inserts the widget into the live overlay (off-screen) so that fonts,
/// images, and platform views are all available during capture.
class WidgetRenderer {
  WidgetRenderer._();

  static GlobalKey<NavigatorState>? _navigatorKey;

  /// Registers the app's [NavigatorState] key so the renderer can access
  /// the [Overlay]. Must be called once before [render].
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
    _navigatorKey = navigatorKey;
  }

  /// Renders [widget] at [size] logical pixels and returns a PNG byte array.
  ///
  /// [pixelRatio] controls the output resolution (default 3.0 for @3x).
  ///
  /// Throws [StateError] if [init] has not been called first.
  static Future<Uint8List> render({
    required Widget widget,
    required Size size,
    double pixelRatio = 3.0,
  }) async {
    final overlay = _navigatorKey?.currentState?.overlay;
    if (overlay == null) {
      throw StateError(
        'FlutterHomescreenWidget.init() must be called with a valid NavigatorKey '
        'before rendering widgets.',
      );
    }

    final completer = Completer<Uint8List>();
    final key = GlobalKey();

    final entry = OverlayEntry(
      builder: (_) => Positioned(
        left: -size.width * 2,
        top: 0,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: RepaintBoundary(
            key: key,
            child: MediaQuery(
              data: const MediaQueryData(),
              child: DefaultTextStyle(
                style: const TextStyle(
                  decoration: TextDecoration.none,
                  color: Color(0xFFFFFFFF),
                ),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: widget,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final boundary =
            key.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: pixelRatio);
        final byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        completer.complete(byteData!.buffer.asUint8List());
      } catch (e, st) {
        completer.completeError(e, st);
      } finally {
        entry.remove();
      }
    });

    return completer.future;
  }
}

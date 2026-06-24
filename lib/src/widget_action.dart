import 'package:flutter/widgets.dart';

/// Defines a tappable area on a home screen widget.
///
/// Coordinates are relative (0.0–1.0) to the widget's rendered size,
/// so the same [WidgetAction] works across all screen densities.
///
/// When the user taps this area, [FlutterHomescreenWidget.onAction] emits [id].
class WidgetAction {
  /// A unique identifier for this action.
  ///
  /// Received via [FlutterHomescreenWidget.onAction] when the user taps the area.
  final String id;

  /// The tappable region in relative coordinates (0.0–1.0).
  ///
  /// Example — right half of the widget:
  /// ```dart
  /// area: const Rect.fromLTWH(0.5, 0.0, 0.5, 1.0)
  /// ```
  final Rect area;

  /// Creates a [WidgetAction] with the given [id] and [area].
  const WidgetAction({
    required this.id,
    required this.area,
  });

  /// Serialises this action to a map for transmission over the platform channel.
  Map<String, dynamic> toMap() => {
        'id': id,
        'left': area.left,
        'top': area.top,
        'width': area.width,
        'height': area.height,
      };
}

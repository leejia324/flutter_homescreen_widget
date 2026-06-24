# flutter_widget_kit

[![pub version](https://img.shields.io/pub/v/flutter_widget_kit.svg)](https://pub.dev/packages/flutter_widget_kit)
[![platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android-blue)](https://pub.dev/packages/flutter_widget_kit)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Update **iOS WidgetKit** and **Android Glance** home screen widgets using Flutter widgets as the UI — design everything in pure Dart, no Swift or Kotlin required.

## Features

- 🎨 **Pure Flutter UI** — any `Widget` becomes your home screen widget
- 📱 **iOS & Android** — WidgetKit (iOS 14+) and Glance (Android 12+)
- 👆 **Tap actions** — map rectangular areas to action IDs and receive callbacks in Dart
- 📐 **Multiple sizes** — small, medium, and large widget families with independent rendering
- 🔄 **Auto-sync** — widget updates as soon as your app changes state

## Getting started

### Install

```yaml
dependencies:
  flutter_widget_kit: ^0.1.0
```

### Initialize

Register a `NavigatorKey` before `runApp` so the renderer can access the overlay:

```dart
final _navKey = GlobalKey<NavigatorState>();

void main() {
  FlutterWidgetKit.init(_navKey);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navKey,
      home: const HomePage(),
    );
  }
}
```

### iOS setup

> Full guide: [doc/ios-setup.md](doc/ios-setup.md)

1. In Xcode, add the **App Groups** capability to both the Runner and Widget Extension targets.
2. Add a **Widget Extension** target: `File → New → Target → Widget Extension`.
3. Copy [`templates/ios/CounterWidget.swift`](templates/ios/CounterWidget.swift) into the extension and set `APP_GROUP_ID`.
4. Register URL scheme `flutterhomewidget` in `Runner/Info.plist` → URL Types.
5. Add `FlutterWidgetKitAppGroup` key to `Runner/Info.plist`.

### Android setup

> Full guide: [doc/android-setup.md](doc/android-setup.md)

1. Add Glance dependencies to `android/app/build.gradle.kts`.
2. Copy [`templates/android/CounterWidget.kt`](templates/android/CounterWidget.kt) into your package.
3. Copy [`templates/android/counter_widget_info.xml`](templates/android/counter_widget_info.xml) to `res/xml/`.
4. Register the receiver in `AndroidManifest.xml`.
5. Add widget action forwarding to `MainActivity.kt`.

## Usage

### Update a widget

```dart
await FlutterWidgetKit.update(
  widgetName: 'CounterWidget',     // must match the native widget `kind`
  size: const Size(329, 155),      // logical size to render at (medium)
  content: CounterUI(count: _n),   // any Flutter widget
  actions: [
    WidgetAction(
      id: 'increment',
      area: const Rect.fromLTWH(0.6, 0.0, 0.4, 0.5), // top-right quadrant
    ),
    WidgetAction(
      id: 'decrement',
      area: const Rect.fromLTWH(0.6, 0.5, 0.4, 0.5), // bottom-right quadrant
    ),
  ],
);
```

### Recommended sizes

| Family | iOS logical size | Android dp |
|--------|-----------------|-----------|
| Small  | `Size(155, 155)` | `180×110` |
| Medium | `Size(329, 155)` | `360×110` |
| Large  | `Size(329, 345)` | `360×280` |

### Receive tap actions

```dart
@override
void initState() {
  super.initState();
  FlutterWidgetKit.onAction.listen((id) {
    if (id == 'increment') _changeCount(1);
    if (id == 'decrement') _changeCount(-1);
  });
}
```

### Reload without re-rendering

```dart
await FlutterWidgetKit.reload(widgetName: 'CounterWidget');
```

## How it works

```
Flutter widget
    │  rendered to PNG via RepaintBoundary (live Overlay)
    ▼
App Group (iOS) / internal storage (Android)
    │  shared between app process and widget process
    ▼
WidgetKit / Glance renders the PNG on the home screen
    │  user taps a defined action area
    ▼
URL scheme deep link  →  Flutter app receives action ID via onAction stream
```

## Limitations

| Limitation | Details |
|-----------|---------|
| Tap opens app | Actions bring the app to the foreground before delivering the event. Background-only processing requires iOS 17+ `AppIntent` (not yet supported). |
| Refresh rate | The OS throttles widget refreshes to preserve battery. |
| Initial setup | A small amount of native configuration is unavoidable (Xcode target + AndroidManifest). Copy-paste templates are provided. |

## Contributing

Pull requests and issues are welcome at [github.com/leejia/flutter_widget_kit](https://github.com/leejia/flutter_widget_kit).

## License

MIT — see [LICENSE](LICENSE).

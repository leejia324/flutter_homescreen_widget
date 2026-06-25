## 0.1.3

* Fix widget renderer to remove yellow text underlines via `DefaultTextStyle`.
* Fix iOS 17+ white widget background by using image as `containerBackground`.
* Update example to glassmorphism clock widget.
* Fix iOS minimum deployment target to 14.0 in example Podfile.

## 0.1.2

* Fix pubspec description length.
* Translate example comments to English.

## 0.1.1

* Rename package from `flutter_widget_kit` to `flutter_homescreen_widget`.

## 0.1.0

* Initial release.
* Render any Flutter widget to a PNG and push it to an iOS WidgetKit or Android Glance home screen widget.
* Define tappable `WidgetAction` areas with relative coordinates (0.0–1.0).
* Receive tap action IDs in your Flutter app via `FlutterHomescreenWidget.onAction` stream.
* Support multiple widget sizes (small, medium, large) with independent update calls.
* iOS: uses App Group shared container + `WidgetCenter.reloadTimelines`.
* Android: uses internal file storage + SharedPreferences + AppWidget broadcast.

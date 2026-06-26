## 0.1.5

* Add Android Glance widget setup to example app.
* Fix example app to render widgets with rounded corners on Android.
* Add example image to README.

## 0.1.4

* Fix template files: remove Korean comments, correct plugin class name to `FlutterHomescreenWidgetPlugin`.
* Fix iOS template: add `FHWBackground` modifier for iOS 17+ `containerBackground` support.
* Fix `doc/ios-setup.md`: correct `FlutterHomescreenWidgetAppGroup` key name.
* Update README: clarify that minimal native boilerplate is still required.

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

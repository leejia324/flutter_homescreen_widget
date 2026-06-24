## 0.1.0

* Initial release.
* Render any Flutter widget to a PNG and push it to an iOS WidgetKit or Android Glance home screen widget.
* Define tappable `WidgetAction` areas with relative coordinates (0.0–1.0).
* Receive tap action IDs in your Flutter app via `FlutterHomescreenWidget.onAction` stream.
* Support multiple widget sizes (small, medium, large) with independent update calls.
* iOS: uses App Group shared container + `WidgetCenter.reloadTimelines`.
* Android: uses internal file storage + SharedPreferences + AppWidget broadcast.

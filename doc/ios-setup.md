# iOS Setup Guide

## 1. Create an App Group

1. In Xcode, select the **Runner** target.
2. Go to **Signing & Capabilities** → **+ Capability** → **App Groups**.
3. Tap **+** and create a group ID in the format `group.com.yourapp.widget`.

## 2. Add a Widget Extension target

1. **File → New → Target → Widget Extension**.
2. Set a Product Name (e.g. `CounterWidget`).
3. Uncheck **Include Configuration Intent**.
4. Add the **App Groups** capability to the new target and select the same group ID.

## 3. Copy the template

Copy `templates/ios/CounterWidget.swift` into the Widget Extension target and update the constant at the top:

```swift
private let APP_GROUP_ID = "group.com.yourapp.widget" // your App Group ID
```

Rename the widget structs and update the `widgetName` strings to match whatever you pass to `FlutterHomescreenWidget.update(widgetName: ...)` in Dart.

## 4. Register a URL scheme

1. Select the **Runner** target → **Info** tab → **URL Types** → **+**.
2. Set **URL Schemes** to `flutterhomewidget`.

## 5. Add the App Group key to Info.plist

```xml
<key>FlutterHomescreenWidgetAppGroup</key>
<string>group.com.yourapp.widget</string>
```

## 6. Verify

Run the app on a device or simulator, add the widget to the home screen, then call `FlutterHomescreenWidget.update()` from Dart. The widget should update within a few seconds.

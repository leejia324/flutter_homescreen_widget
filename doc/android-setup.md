# Android Setup Guide

## 1. Add Glance dependencies

In `android/app/build.gradle.kts`, add to the `dependencies` block:

```kotlin
implementation("androidx.glance:glance-appwidget:1.1.0")
implementation("androidx.glance:glance-material3:1.1.0")
```

## 2. Copy the widget template

Copy `templates/android/CounterWidget.kt` to
`android/app/src/main/kotlin/<your/package>/CounterWidget.kt`
and update the package declaration and widget name constant:

```kotlin
package com.yourpackage
private const val WIDGET_NAME = "CounterWidget" // must match FlutterHomescreenWidget.update(widgetName: ...)
```

## 3. Copy the widget info XML

Copy `templates/android/counter_widget_info.xml` to
`android/app/src/main/res/xml/counter_widget_info.xml`.

## 4. Register the receiver in AndroidManifest.xml

Inside the `<application>` tag:

```xml
<receiver
    android:name=".CounterWidgetReceiver"
    android:exported="true">
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
    </intent-filter>
    <meta-data
        android:name="android.appwidget.provider"
        android:resource="@xml/counter_widget_info" />
</receiver>
```

## 5. Update MainActivity

Merge the `handleWidgetAction` logic from `templates/android/MainActivity.kt` into your existing `MainActivity.kt` (add calls in `onCreate` and `onNewIntent`).

## 6. Verify

Add the widget to the home screen on an emulator or device, then call `FlutterHomescreenWidget.update()` from Dart. Tapping the widget should open the app and deliver the action ID via `FlutterHomescreenWidget.onAction`.

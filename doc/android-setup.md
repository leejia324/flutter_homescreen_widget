# Android 설정 가이드

## 1. Glance 의존성 추가

`android/app/build.gradle.kts` 의 `dependencies` 블록에 추가:

```kotlin
implementation("androidx.glance:glance-appwidget:1.1.0")
implementation("androidx.glance:glance-material3:1.1.0")
```

## 2. 템플릿 파일 복사

`templates/android/CounterWidget.kt` 를
`android/app/src/main/kotlin/<your/package>/CounterWidget.kt` 에 복사 후
파일 상단 `package` 와 `WIDGET_NAME` 수정:

```kotlin
package com.yourpackage          // 본인 패키지명
private const val WIDGET_NAME = "CounterWidget"  // FlutterHomeWidget.update(widgetName:) 과 동일
```

## 3. 위젯 정보 XML 추가

`templates/android/counter_widget_info.xml` 을
`android/app/src/main/res/xml/counter_widget_info.xml` 에 복사.

## 4. AndroidManifest.xml 에 리시버 등록

`<application>` 태그 안에 추가:

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

## 5. MainActivity 수정

`templates/android/MainActivity.kt` 의 `handleWidgetAction` 로직을
기존 `MainActivity.kt` 에 추가 (onCreate, onNewIntent).

## 6. 확인

에뮬레이터 또는 실기기 홈 화면에서 위젯 추가.
앱에서 `FlutterHomeWidget.update()` 호출 시 위젯이 업데이트되어야 합니다.
위젯의 + / - 버튼 탭 시 앱이 열리고 `FlutterHomeWidget.onAction` 스트림으로 actionId가 전달됩니다.

# iOS 설정 가이드

## 1. App Group 생성

1. Xcode → Runner 타겟 선택
2. **Signing & Capabilities** 탭 → **+ Capability** → **App Groups** 추가
3. `+` 버튼 → `group.com.yourapp.widget` 형식으로 생성 (본인 번들 ID 사용)

## 2. Widget Extension 추가

1. Xcode → **File → New → Target → Widget Extension**
2. Product Name: `CounterWidget` (또는 원하는 이름)
3. Include Configuration Intent: **체크 해제**
4. Widget Extension 타겟도 **App Groups** Capability 추가 (위와 동일한 그룹 선택)

## 3. 템플릿 파일 복사

`templates/ios/CounterWidget.swift` 내용을 Widget Extension 타겟의 Swift 파일에 붙여넣고,
파일 상단의 두 상수를 수정합니다:

```swift
private let WIDGET_NAME  = "CounterWidget"            // FlutterHomeWidget.update(widgetName:) 과 동일
private let APP_GROUP_ID = "group.com.yourapp.widget" // 위에서 만든 App Group ID
```

## 4. URL Scheme 등록 (딥링크)

1. Xcode → Runner 타겟 → **Info** 탭
2. **URL Types** → `+` 추가
3. URL Schemes: `flutterhomewidget`

## 5. Info.plist에 App Group ID 추가

```xml
<key>FlutterHomeWidgetAppGroup</key>
<string>group.com.yourapp.widget</string>
```

## 6. 확인

시뮬레이터 또는 실기기에서 앱 실행 후 홈 화면에 위젯 추가.
앱에서 `FlutterHomeWidget.update()` 호출 시 위젯이 업데이트되어야 합니다.

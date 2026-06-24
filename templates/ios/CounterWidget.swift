// ============================================================
// flutter_home_widget — iOS WidgetKit Extension 템플릿
//
// 사용법:
// 1. Xcode → File → New → Target → Widget Extension 추가
// 2. 이 파일을 해당 타겟에 복붙
// 3. APP_GROUP_ID 를 본인 값으로 교체
// 4. URL Scheme "flutterhomewidget" 을 Info.plist에 등록
// ============================================================

import WidgetKit
import SwiftUI

// MARK: - 설정값 (수정 필요)
private let APP_GROUP_ID = "group.com.yourapp.widget" // Xcode → Signing & Capabilities → App Groups

// MARK: - 공통 모델

struct FHWAction: Identifiable, Decodable {
    let id: String
    let left: Double
    let top: Double
    let width: Double
    let height: Double
}

struct FHWEntry: TimelineEntry {
    let date: Date
    let image: UIImage?
    let actions: [FHWAction]
}

// MARK: - 공통 로더

func loadEntry(widgetName: String) -> FHWEntry {
    let container = FileManager.default.containerURL(
        forSecurityApplicationGroupIdentifier: APP_GROUP_ID
    )

    var image: UIImage?
    if let url = container?.appendingPathComponent("\(widgetName).png"),
       let data = try? Data(contentsOf: url) {
        image = UIImage(data: data)
    }

    var actions: [FHWAction] = []
    if let url = container?.appendingPathComponent("\(widgetName)_actions.json"),
       let data = try? Data(contentsOf: url) {
        actions = (try? JSONDecoder().decode([FHWAction].self, from: data)) ?? []
    }

    return FHWEntry(date: .now, image: image, actions: actions)
}

// MARK: - 공통 View

struct FHWView: View {
    let entry: FHWEntry

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if let image = entry.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Color(.systemGray5)
                    Text("앱을 열어 위젯을 업데이트하세요")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }

                ForEach(entry.actions) { action in
                    Link(destination: URL(string: "flutterhomewidget://action/\(action.id)")!) {
                        Color.clear
                    }
                    .frame(
                        width:  geo.size.width  * action.width,
                        height: geo.size.height * action.height
                    )
                    .position(
                        x: geo.size.width  * (action.left + action.width  / 2),
                        y: geo.size.height * (action.top  + action.height / 2)
                    )
                }
            }
        }
    }
}

// MARK: - Medium 위젯 (가로형, +/- 버튼)

struct CounterWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> FHWEntry { FHWEntry(date: .now, image: nil, actions: []) }
    func getSnapshot(in context: Context, completion: @escaping (FHWEntry) -> Void) { completion(loadEntry(widgetName: "CounterWidget")) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<FHWEntry>) -> Void) {
        completion(Timeline(entries: [loadEntry(widgetName: "CounterWidget")], policy: .never))
    }
}

struct CounterWidget: Widget {
    let kind = "CounterWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CounterWidgetProvider()) { entry in
            FHWView(entry: entry)
        }
        .configurationDisplayName("Counter (Medium)")
        .description("탭으로 카운터를 조작하는 위젯")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Small 위젯 (정사각형, 탭하면 +1)

struct CounterWidgetSmallProvider: TimelineProvider {
    func placeholder(in context: Context) -> FHWEntry { FHWEntry(date: .now, image: nil, actions: []) }
    func getSnapshot(in context: Context, completion: @escaping (FHWEntry) -> Void) { completion(loadEntry(widgetName: "CounterWidgetSmall")) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<FHWEntry>) -> Void) {
        completion(Timeline(entries: [loadEntry(widgetName: "CounterWidgetSmall")], policy: .never))
    }
}

struct CounterWidgetSmall: Widget {
    let kind = "CounterWidgetSmall"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CounterWidgetSmallProvider()) { entry in
            FHWView(entry: entry)
        }
        .configurationDisplayName("Counter (Small)")
        .description("탭하면 카운터가 +1 증가")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - WidgetBundle (두 위젯을 함께 등록)

@main
struct CounterWidgetBundle: WidgetBundle {
    var body: some Widget {
        CounterWidget()
        CounterWidgetSmall()
    }
}

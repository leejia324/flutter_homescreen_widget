import WidgetKit
import SwiftUI

// MARK: - Config (edit this)
private let APP_GROUP_ID = "group.com.leejia.flutterhomewidget"

// MARK: - Shared model

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

// MARK: - Loader

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

// MARK: - Shared view

struct FHWView: View {
    let entry: FHWEntry

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if entry.image == nil {
                    Color(.systemGray5)
                    Text("Open the app to update the widget")
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
        .modifier(FHWBackground(image: entry.image))
    }
}

// MARK: - Background modifier (image as containerBackground on iOS 17+)

struct FHWBackground: ViewModifier {
    let image: UIImage?

    func body(content: Content) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            content
                .containerBackground(for: .widget) {
                    if let img = image {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Color(.systemGray5)
                    }
                }
        } else {
            ZStack {
                if let img = image {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                }
                content
            }
        }
    }
}

// MARK: - Medium widget

struct ClockWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> FHWEntry { FHWEntry(date: .now, image: nil, actions: []) }
    func getSnapshot(in context: Context, completion: @escaping (FHWEntry) -> Void) { completion(loadEntry(widgetName: "ClockWidget")) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<FHWEntry>) -> Void) {
        completion(Timeline(entries: [loadEntry(widgetName: "ClockWidget")], policy: .after(.now.addingTimeInterval(60))))
    }
}

struct ClockWidget: Widget {
    let kind = "ClockWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ClockWidgetProvider()) { entry in
            FHWView(entry: entry)
        }
        .configurationDisplayName("Clock (Medium)")
        .description("Glassmorphism clock widget")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Small widget

struct ClockWidgetSmallProvider: TimelineProvider {
    func placeholder(in context: Context) -> FHWEntry { FHWEntry(date: .now, image: nil, actions: []) }
    func getSnapshot(in context: Context, completion: @escaping (FHWEntry) -> Void) { completion(loadEntry(widgetName: "ClockWidgetSmall")) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<FHWEntry>) -> Void) {
        completion(Timeline(entries: [loadEntry(widgetName: "ClockWidgetSmall")], policy: .after(.now.addingTimeInterval(60))))
    }
}

struct ClockWidgetSmall: Widget {
    let kind = "ClockWidgetSmall"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ClockWidgetSmallProvider()) { entry in
            FHWView(entry: entry)
        }
        .configurationDisplayName("Clock (Small)")
        .description("Compact glassmorphism clock")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - WidgetBundle

@main
struct ClockWidgetBundle: WidgetBundle {
    var body: some Widget {
        ClockWidget()
        ClockWidgetSmall()
    }
}

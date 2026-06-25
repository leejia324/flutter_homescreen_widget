import WidgetKit
import SwiftUI

// Change this to your App Group ID (Xcode → Signing & Capabilities → App Groups)
private let APP_GROUP_ID = "group.com.yourapp.widget"

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

struct FHWBackground: ViewModifier {
    let image: UIImage?

    func body(content: Content) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            content
                .containerBackground(for: .widget) {
                    if let img = image {
                        Image(uiImage: img).resizable().scaledToFill()
                    } else {
                        Color(.systemGray5)
                    }
                }
        } else {
            ZStack {
                if let img = image {
                    Image(uiImage: img).resizable().scaledToFill()
                }
                content
            }
        }
    }
}

// MARK: - Widget definitions
// Rename these structs and update widgetName to match your FlutterHomescreenWidget.update(widgetName:) calls.

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
        .configurationDisplayName("Counter")
        .description("A Flutter-rendered counter widget.")
        .supportedFamilies([.systemMedium])
    }
}

@main
struct CounterWidgetBundle: WidgetBundle {
    var body: some Widget {
        CounterWidget()
    }
}

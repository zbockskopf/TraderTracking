//
//  TraderWidgets.swift
//  TraderWidgets
//
//  Created by Zach Bockskopf on 1/7/24.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct TraderWidgetsEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)

            Text("Favorite Emoji:")
            Text(entry.configuration.favoriteEmoji)
        }
    }
}

struct TraderWidgets: Widget {
    let kind: String = "TraderWidgets"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            TraderWidgetsEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

//#Preview(as: .systemSmall) {
//    EventsWidget()
//}

//import WidgetKit
//import SwiftUI
//
//struct Event: Identifiable {
//    let id = UUID()
//    let title: String
//    let time: String
//}
//
//struct Provider: TimelineProvider {
//    func placeholder(in context: Context) -> SimpleEntry {
//        SimpleEntry(date: Date(), events: sampleEvents)
//    }
//
//    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
//        let entry = SimpleEntry(date: Date(), events: sampleEvents)
//        completion(entry)
//    }
//
//    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
//        var entries: [SimpleEntry] = []
//
//        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//        let currentDate = Date()
//        for hourOffset in 0 ..< 5 {
//            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//            let entry = SimpleEntry(date: entryDate, events: sampleEvents)
//            entries.append(entry)
//        }
//
//        let timeline = Timeline(entries: entries, policy: .atEnd)
//        completion(timeline)
//    }
//}
//
//struct SimpleEntry: TimelineEntry {
//    let date: Date
//    let events: [Event]
//}
//
//struct WidgetEntryView : View {
//    var entry: Provider.Entry
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("Today's Events")
//                .font(.headline)
//            ForEach(entry.events) { event in
//                HStack {
//                    Text(event.time)
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                    Text(event.title)
//                        .font(.body)
//                }
//            }
//        }
//        .padding()
//    }
//}
//
//@main
//struct EventsWidget: Widget {
//    let kind: String = "EventsWidget"
//
//    var body: some WidgetConfiguration {
//        StaticConfiguration(kind: kind, provider: Provider()) { entry in
//            WidgetEntryView(entry: entry)
//        }
//        .configurationDisplayName("Today's Events")
//        .description("View today's events.")
//    }
//}
//
//struct EventsWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        WidgetEntryView(entry: SimpleEntry(date: Date(), events: sampleEvents))
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
//    }
//}
//
//let sampleEvents = [
//    Event(title: "Meeting with Bob", time: "9:00 AM"),
//    Event(title: "Lunch with Alice", time: "12:00 PM"),
//    Event(title: "Project Review", time: "3:00 PM")
//]


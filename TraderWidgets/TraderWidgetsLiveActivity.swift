//
//  TraderWidgetsLiveActivity.swift
//  TraderWidgets
//
//  Created by Zach Bockskopf on 1/7/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TraderWidgetsAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct TraderWidgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TraderWidgetsAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension TraderWidgetsAttributes {
    fileprivate static var preview: TraderWidgetsAttributes {
        TraderWidgetsAttributes(name: "World")
    }
}

extension TraderWidgetsAttributes.ContentState {
    fileprivate static var smiley: TraderWidgetsAttributes.ContentState {
        TraderWidgetsAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: TraderWidgetsAttributes.ContentState {
         TraderWidgetsAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: TraderWidgetsAttributes.preview) {
   TraderWidgetsLiveActivity()
} contentStates: {
    TraderWidgetsAttributes.ContentState.smiley
    TraderWidgetsAttributes.ContentState.starEyes
}

//
//  StatsWidget.swift
//  ken
//
//  Created by Lakshay Gupta on 25/04/25.
//

import SwiftUI
import WidgetKit

struct StatsWidget: Widget {
    @Environment(\.colorScheme) var colorScheme

    let kind: String = "kenStatsWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectUserIntent.self, provider: StatsProvider()) { entry in
            if #available(iOS 17.0, *) {
                StatsWidgetEntryView(entry: entry)
                    .containerBackground(colorScheme == .dark ? Color(UIColor(hex: "#202020") ?? .black) : Color.white, for: .widget)

            } else {
                StatsWidgetEntryView(entry: entry)
                    .padding()
                    .background(colorScheme == .dark ? Color(UIColor(hex: "#202020") ?? .black) : Color.white)

            }
        }
        .configurationDisplayName("LeetCode Stats")
        .description("Shows your LeetCode problem-solving statistics")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemMedium) {
    StatsWidget()
} timeline: {
    StatsWidgetEntry.placeholder
}

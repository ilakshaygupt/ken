//
//  StatsWidget.swift
//  ken
//
//  Created by Lakshay Gupta on 25/04/25.
//

import SwiftUI
import WidgetKit

struct StatsWidget: Widget {
    let kind: String = "kenStatsWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectUserIntent.self, provider: StatsProvider()) { entry in
            if #available(iOS 17.0, *) {
                StatsWidgetEntryView(entry: entry)
                    .containerBackground(Color(UIColor(hex: "#202020") ?? UIColor.black), for: .widget)
            } else {
                StatsWidgetEntryView(entry: entry)
                    .padding()
                    .background(Color(.systemBackground))
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

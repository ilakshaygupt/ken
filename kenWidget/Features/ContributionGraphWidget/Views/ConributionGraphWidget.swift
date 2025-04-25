//
//  kenWidget.swift
//  kenWidget
//
//  Created by Lakshay Gupta on 31/01/25.
//

import SwiftUI
import WidgetKit

struct kenWidget: Widget {
    let kind: String = "kenWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectUserIntent.self, provider: UserProvider()) { entry in
            if #available(iOS 17.0, *) {
                ContributionWidgetEntryView(entry: entry)
                    .containerBackground(Color(UIColor(hex: "#202020") ?? UIColor.white), for: .widget)
            } else {
                ContributionWidgetEntryView(entry: entry)
                    .padding()
                    .background(Color(.systemBackground))
            }
        }
        .configurationDisplayName("LeetCode Activity")
        .description("Shows your LeetCode contribution graph")
        .supportedFamilies([.systemLarge,.systemMedium,.systemSmall])
    }
}


#Preview(as: .systemMedium) {
    kenWidget()
} timeline: {
    ContributionWidgetEntry(date: .now, username: "NO USER", contributions: [
        .init(date: Date(), count: 0),
        .init(date: Date().addingTimeInterval(-86400), count: 2),
        .init(date: Date().addingTimeInterval(-86400 * 2), count: 5),
        .init(date: Date().addingTimeInterval(-86400 * 3), count: 1),
        .init(date: Date().addingTimeInterval(-86400 * 4), count: 3)
    ])
}

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
                    .containerBackgroundForWidget()

            } else {
                StatsWidgetEntryView(entry: entry)
                    .padding()
                    .containerBackgroundForWidget()

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

extension View {
    func containerBackgroundForWidget() -> some View {
        if #available(iOS 17.0, *) {
            return self.containerBackground(for: .widget) {
                Color(UIColor { traitCollection in
                    return traitCollection.userInterfaceStyle == .dark ?
                           UIColor(hex: "#202020") ?? .black : .white
                })
            }
        } else {
            return self.background(
                Color(UIColor { traitCollection in
                    return traitCollection.userInterfaceStyle == .dark ?
                           UIColor(hex: "#202020") ?? .black : .white
                })
            )
            .padding()
        }
    }
}

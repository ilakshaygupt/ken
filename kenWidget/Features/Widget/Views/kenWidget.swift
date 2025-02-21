//
//  kenWidget.swift
//  kenWidget
//
//  Created by Lakshay Gupta on 31/01/25.
//

import WidgetKit
import SwiftUI
import Combine

struct Provider: TimelineProvider {
    typealias Entry = SimpleEntry
    
    private let userDefaultsKey = "leetcode_usernames"
    private var cancellables = Set<AnyCancellable>()
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry.placeholder
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        // Get usernames from UserDefaults
        guard let usernames = UserDefaults(suiteName: AppGroup)!.stringArray(forKey: userDefaultsKey),
              let username = usernames.first else {
            completion(Timeline(entries: [SimpleEntry.placeholder], policy: .after(Date().addingTimeInterval(3600))))
            return
        }
        
        var cancellable: AnyCancellable?
        
        cancellable = LeetCode.getUserCalendar(for: username, queue: .global())
            .sink(
                receiveCompletion: { completionResult in
                    if case .failure = completionResult {
                        let timeline = Timeline(entries: [SimpleEntry.placeholder], policy: .after(Date().addingTimeInterval(3600)))
                        completion(timeline)
                    }
                    cancellable?.cancel()
                },
                receiveValue: { calendar in
                    let contributions = LeetCode.UserCalendar.DailyContribution.parse(from: calendar.submissionCalendar)
                    let entry = SimpleEntry(date: Date(), username: username, contributions: contributions)
                    let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
                    completion(timeline)
                    cancellable?.cancel()
                }
            )
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let username: String
    let contributions: [LeetCode.UserCalendar.DailyContribution]
    
    static let placeholder: SimpleEntry = {
        SimpleEntry(date: Date(), username: "NO USER", contributions: [])
    }()
}

struct WidgetContributionGridView: View {
    let contributions: [LeetCode.UserCalendar.DailyContribution]
    private let cellSize: CGFloat = 4
    private let spacing: CGFloat = 2
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(cellSize), spacing: spacing), count: 7), spacing: spacing) {
            ForEach(contributions.suffix(49), id: \.date) { contribution in
                RoundedRectangle(cornerRadius: 1)
                    .fill(ContributionColors.color(for: contribution.count))
                    .frame(width: cellSize, height: cellSize)
                    .overlay(
                        RoundedRectangle(cornerRadius: 1)
                            .strokeBorder(Color.black.opacity(0.2), lineWidth: 0.5)
                    )
            }
        }
    }
}

struct kenWidgetEntryView: View {
    var entry: SimpleEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        VStack(spacing: 0) { // Added spacing for better layout
            HStack(spacing: 5) {
                Image("leetcode")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)

                Text(entry.username)
                    .font(.caption2)
                    .bold()
            }
            .frame(maxWidth: .infinity) // Center horizontally

            ContributionGridWidgetView(contributions: entry.contributions)
                .frame(maxWidth: .infinity) // Center horizontally
        }
        .frame(maxWidth: .infinity, alignment: .center) // Ensure VStack takes full width
        .multilineTextAlignment(.center) // Align text content to center
        .widgetURL(URL(string: "leetcode://user/\(entry.username)"))
    }

}

struct kenWidget: Widget {
    let kind: String = "kenWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectUserIntent.self, provider: UserProvider()) { entry in
            if #available(iOS 17.0, *) {
                kenWidgetEntryView(entry: entry)
                    .containerBackground(Color(UIColor(hex: "#202020") ?? UIColor.white), for: .widget)



            } else {
                kenWidgetEntryView(entry: entry)
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
    SimpleEntry(date: .now, username: "NO USER", contributions: [
        .init(date: Date(), count: 0),
        .init(date: Date().addingTimeInterval(-86400), count: 2),
        .init(date: Date().addingTimeInterval(-86400 * 2), count: 5),
        .init(date: Date().addingTimeInterval(-86400 * 3), count: 1),
        .init(date: Date().addingTimeInterval(-86400 * 4), count: 3)
    ])
}

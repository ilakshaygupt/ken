//
//  LeetCodeTrackedSource.swift
//  ken
//

import Foundation

/// Pure wrapper around existing LeetCode models — no new network/parsing code.
struct LeetCodeTrackedSource: TrackedSource {
    static var kind: TrackedSourceKind { .leetcode }
    let username: String
    let stats: UserStats
    let calendar: UserCalendar

    var id: TrackedSourceID { TrackedSourceID(kind: .leetcode, identifier: username) }
    var displayName: String { username }
    var activity: [DailyContribution] { calendar.contributions }
    var refreshPolicy: TrackedSourceRefreshPolicy { .networkTTL(seconds: 3600) }

    var summaryStats: [TrackedSourceStat] {
        [
            TrackedSourceStat(label: "Solved", value: "\(stats.totalSolved)", icon: "checkmark.circle.fill"),
            TrackedSourceStat(label: "Streak", value: "\(calendar.streak)", icon: "flame.fill"),
            TrackedSourceStat(label: "Rank", value: stats.ranking.map { "#\($0)" } ?? "-", icon: "trophy.fill"),
        ]
    }
}

//
//  TrackedSource.swift
//  ken
//

import Foundation

/// Small display-only summary chip (e.g. "Streak: 12"). Not a replacement for
/// rich per-source models like UserStats — LeetCode's detailed ring/difficulty
/// breakdown keeps using LeetCodeViewModel directly.
struct TrackedSourceStat: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    let icon: String?
}

enum TrackedSourceRefreshPolicy {
    case networkTTL(seconds: TimeInterval)
    case localOnly
}

/// Normalizes any source into: identity, a per-day activity map, summary stats,
/// and a refresh policy.
protocol TrackedSource {
    static var kind: TrackedSourceKind { get }
    var id: TrackedSourceID { get }
    var displayName: String { get }
    var activity: [DailyContribution] { get }
    var summaryStats: [TrackedSourceStat] { get }
    var refreshPolicy: TrackedSourceRefreshPolicy { get }
}

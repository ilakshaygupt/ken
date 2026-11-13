//
//  AnyTrackedSource.swift
//  ken
//

import Foundation

/// Type-erased, display-ready snapshot of any TrackedSource. Associated-type
/// protocols can't be stored heterogeneously, so any screen that mixes source
/// kinds should consume this, not `any TrackedSource`.
struct AnyTrackedSource: Identifiable {
    let id: TrackedSourceID
    let kind: TrackedSourceKind
    let displayName: String
    let activity: [DailyContribution]
    let summaryStats: [TrackedSourceStat]
    let refreshPolicy: TrackedSourceRefreshPolicy

    init<S: TrackedSource>(_ source: S) {
        self.id = source.id
        self.kind = S.kind
        self.displayName = source.displayName
        self.activity = source.activity
        self.summaryStats = source.summaryStats
        self.refreshPolicy = source.refreshPolicy
    }
}

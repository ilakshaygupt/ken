//
//  LeetCodeViewModel+TrackedSource.swift
//  ken
//
//  Kept out of LeetCodeViewModel.swift itself because that file is also
//  compiled into kenWidgetExtension, which doesn't have the Engine types.

import Foundation

extension LeetCodeViewModel {
    func trackedSource(for username: String) -> AnyTrackedSource? {
        guard let stats = userStats[username], let calendar = userCalendars[username] else { return nil }
        return AnyTrackedSource(LeetCodeTrackedSource(username: username, stats: stats, calendar: calendar))
    }
}

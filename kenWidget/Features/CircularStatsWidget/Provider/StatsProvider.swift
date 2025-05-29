//
//  StatsProvider.swift
//  ken
//
//  Created by Lakshay Gupta on 25/04/25.
//
import WidgetKit
import Alamofire

struct StatsProvider: AppIntentTimelineProvider {
    let viewModel = WidgetSavedUsersViewModel()
    
    func placeholder(in context: Context) -> StatsWidgetEntry {
        StatsWidgetEntry.placeholder
    }
    
    func snapshot(for configuration: SelectUserIntent, in context: Context) async -> StatsWidgetEntry {
        let username = configuration.username ?? viewModel.savedUsernames.first ?? "NO USER"
        
        if let stats = viewModel.getUserStats(for: username) {
            return StatsWidgetEntry(date: Date(), username: username, stats: stats)
        }
        
        return StatsWidgetEntry.placeholder
    }
    
    func timeline(for configuration: SelectUserIntent, in context: Context) async -> Timeline<StatsWidgetEntry> {
        let username = configuration.username ?? viewModel.savedUsernames.first ?? "NO USER"
        
        if username == "NO USER" {
            return Timeline(entries: [StatsWidgetEntry.placeholder], policy: .after(Date().addingTimeInterval(3600)))
        }

        let viewModel = LeetCodeViewModel()
        
        if let stats = viewModel.userStats[username] {
            let entry = StatsWidgetEntry(date: Date(), username: username, stats: stats)
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))

            Task {
                _ = await viewModel.fetchData(for: username, forceRefresh: true)
                WidgetCenter.shared.reloadTimelines(ofKind: "kenStatsWidget")
            }

            return timeline
        } else {
            if await viewModel.fetchData(for: username) {
                if let stats = viewModel.userStats[username] {
                    let entry = StatsWidgetEntry(date: Date(), username: username, stats: stats)
                    return Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
                }
            }
        }

        return Timeline(entries: [StatsWidgetEntry.placeholder], policy: .after(Date().addingTimeInterval(3600)))
    }
}

//
//  UserProvider.swift
//  ken
//
//  Created by Lakshay Gupta on 25/04/25.
//
import WidgetKit
import Intents
import Alamofire

struct UserProvider: AppIntentTimelineProvider {
    let viewModel = WidgetSavedUsersViewModel()
    
    func placeholder(in context: Context) -> ContributionWidgetEntry {
        ContributionWidgetEntry.placeholder
    }

    func snapshot(for configuration: SelectUserIntent, in context: Context) async -> ContributionWidgetEntry {
        let username = configuration.username ?? viewModel.savedUsernames.first ?? "NO USER"
        
        if let calendar = viewModel.getUserCalendar(for: username) {
            let contributions = DailyContribution.parse(from: calendar.submissionCalendar)
            return ContributionWidgetEntry(date: Date(), username: username, contributions: contributions)
        }
        
        return ContributionWidgetEntry.placeholder
    }

    func timeline(for configuration: SelectUserIntent, in context: Context) async -> Timeline<ContributionWidgetEntry> {
        let username = configuration.username ?? viewModel.savedUsernames.first ?? "NO USER"
        
        if username == "NO USER" {
            return Timeline(entries: [ContributionWidgetEntry.placeholder], policy: .after(Date().addingTimeInterval(3600)))
        }

        let viewModel = LeetCodeViewModel()

        if let calendar = viewModel.userCalendars[username] {
            let contributions = DailyContribution.parse(from: calendar.submissionCalendar)
            let entry = ContributionWidgetEntry(date: Date(), username: username, contributions: contributions)
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))

            Task {
                _ = await viewModel.fetchData(for: username, forceRefresh: true)
                WidgetCenter.shared.reloadTimelines(ofKind: "kenWidget")
            }

            return timeline
        } else {
            if await viewModel.fetchData(for: username) {
                if let calendar = viewModel.userCalendars[username] {
                    let contributions = DailyContribution.parse(from: calendar.submissionCalendar)
                    let entry = ContributionWidgetEntry(date: Date(), username: username, contributions: contributions)
                    return Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
                }
            }
        }

        return Timeline(entries: [ContributionWidgetEntry.placeholder], policy: .after(Date().addingTimeInterval(3600)))
    }
}

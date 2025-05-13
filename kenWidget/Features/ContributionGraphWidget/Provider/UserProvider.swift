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

        let storageService = LeetCodeJSONStorageService()

        if let calendar = viewModel.getUserCalendar(for: username) {
            let contributions = DailyContribution.parse(from: calendar.submissionCalendar)
            let entry = ContributionWidgetEntry(date: Date(), username: username, contributions: contributions)
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))

            Task {
                do {
                    let freshCalendarData = try await fetchCalendarJSONData(for: username)
                    storageService.saveCalendarJSONResponse(freshCalendarData, forUsername: username)
                    WidgetCenter.shared.reloadTimelines(ofKind: "kenWidget")
                } catch {
                }
            }

            return timeline
        } else {
            do {
                let calendarData = try await fetchCalendarJSONData(for: username)
                storageService.saveCalendarJSONResponse(calendarData, forUsername: username)

                if let calendar = LeetCodeJSONParser.parseUserCalendar(from: calendarData) {
                    let contributions = DailyContribution.parse(from: calendar.submissionCalendar)
                    let entry = ContributionWidgetEntry(date: Date(), username: username, contributions: contributions)
                    return Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
                }
            } catch {
            }
        }

        return Timeline(entries: [ContributionWidgetEntry.placeholder], policy: .after(Date().addingTimeInterval(3600)))
    }

    
    
    private func fetchCalendarJSONData(for username: String) async throws -> Data {
        let query = GraphQLQueries.userCalendar
        let variables = ["username": username]
        let url = "https://leetcode.com/graphql"
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Referer": "https://leetcode.com"
        ]
        let body: [String: Any] = [
            "query": query,
            "variables": variables,
            "operationName": "userProfileCalendar"
        ]

        // Use Alamofire's async/await API
        let data = try await AF.request(
            url,
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: headers
        ).serializingData().value

        return data
    }
}

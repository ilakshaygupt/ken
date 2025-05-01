//
//  UserProvider.swift
//  ken
//
//  Created by Lakshay Gupta on 25/04/25.
//
import WidgetKit
import Intents

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

                if let calendar = storageService.parseUserCalendar(from: calendarData) {
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
        
        var request = URLRequest(url: URL(string: "https://leetcode.com/graphql")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("https://leetcode.com", forHTTPHeaderField: "Referer")
        
        let body = [
            "query": query,
            "variables": variables,
            "operationName": "userProfileCalendar"
        ] as [String : Any]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return data
    }
}

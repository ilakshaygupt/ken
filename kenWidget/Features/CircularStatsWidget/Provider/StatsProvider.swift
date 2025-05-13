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

        let storageService = LeetCodeJSONStorageService()
        
        if let stats = viewModel.getUserStats(for: username) {
            let entry = StatsWidgetEntry(date: Date(), username: username, stats: stats)
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))

            Task {
                do {
                    let freshStatsData = try await fetchStatsJSONData(for: username)
                    storageService.saveStatsJSONResponse(freshStatsData, forUsername: username)
                    WidgetCenter.shared.reloadTimelines(ofKind: "kenStatsWidget")
                } catch {
                }
            }

            return timeline
        } else {
            do {
                let statsData = try await fetchStatsJSONData(for: username)
                storageService.saveStatsJSONResponse(statsData, forUsername: username)

                if let stats = LeetCodeJSONParser.parseUserStats(from: statsData) {
                    let entry = StatsWidgetEntry(date: Date(), username: username, stats: stats)
                    return Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
                }
            } catch {
            }
        }

        return Timeline(entries: [StatsWidgetEntry.placeholder], policy: .after(Date().addingTimeInterval(3600)))
    }

        
    private func fetchStatsJSONData(for username: String) async throws -> Data {
        let query = GraphQLQueries.userStats
        let variables = ["username": username]
        let url = "https://leetcode.com/graphql"
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Referer": "https://leetcode.com"
        ]
        let body: [String: Any] = [
            "query": query,
            "variables": variables
        ]

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

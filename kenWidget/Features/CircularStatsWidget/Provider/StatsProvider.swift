//
//  StatsProvider.swift
//  ken
//
//  Created by Lakshay Gupta on 25/04/25.
//
import WidgetKit

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

                if let stats = storageService.parseUserStats(from: statsData) {
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
        
        var request = URLRequest(url: URL(string: "https://leetcode.com/graphql")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("https://leetcode.com", forHTTPHeaderField: "Referer")
        
        let body = [
            "query": query,
            "variables": variables
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

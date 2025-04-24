//
//  WidgetSavedUsersViewModel.swift
//  ken
//
//  Created by Lakshay Gupta on 31/01/25.
//

import WidgetKit
import AppIntents
import Intents
import Combine

class WidgetSavedUsersViewModel: ObservableObject {
    @Published var savedUsernames: [String] = []
    private let userDefaultsKey = "leetcode_usernames"
    private let storageService = LeetCodeJSONStorageService()
    
    init() {
        loadSavedUsernames()
    }
    
    func loadSavedUsernames() {
        if let usernames = UserDefaults(suiteName: AppGroup)!.stringArray(forKey: userDefaultsKey) {
            savedUsernames = usernames
        }
    }
    
    func getUserCalendar(for username: String) -> LeetCode.UserCalendar? {
        if let calendarData = storageService.getCalendarJSONResponse(forUsername: username) {
            return storageService.parseUserCalendar(from: calendarData)
        }
        return nil
    }
    
    func getUserStats(for username: String) -> LeetCode.UserStats? {
        if let statsData = storageService.getStatsJSONResponse(forUsername: username) {
            return storageService.parseUserStats(from: statsData)
        }
        return nil
    }
}

struct SelectUserIntent: AppIntent, WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select User"
    static var description = IntentDescription("Choose a LeetCode user to display")

    @Parameter(title: "LeetCode Username", optionsProvider: UsernameOptionsProvider())
    var username: String?
    
    init() {
        let viewModel = WidgetSavedUsersViewModel()
        self.username = viewModel.savedUsernames.first ?? "NO USER"
    }
}

struct UsernameOptionsProvider: DynamicOptionsProvider {
    func results() async throws -> [String] {
        let viewModel = WidgetSavedUsersViewModel()
        if viewModel.savedUsernames.isEmpty {
            return ["NO USER"]
        }
        return viewModel.savedUsernames
    }
    
    func defaultResult() async -> String {
        let viewModel = WidgetSavedUsersViewModel()
        return viewModel.savedUsernames.first ?? "NO USER"
    }
}

struct UserProvider: AppIntentTimelineProvider {
    let viewModel = WidgetSavedUsersViewModel()
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry.placeholder
    }

    func snapshot(for configuration: SelectUserIntent, in context: Context) async -> SimpleEntry {
        let username = configuration.username ?? viewModel.savedUsernames.first ?? "NO USER"
        
        // 
        if let calendar = viewModel.getUserCalendar(for: username) {
            let contributions = LeetCode.UserCalendar.DailyContribution.parse(from: calendar.submissionCalendar)
            return SimpleEntry(date: Date(), username: username, contributions: contributions)
        }
        
        return SimpleEntry.placeholder
    }

    func timeline(for configuration: SelectUserIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let username = configuration.username ?? viewModel.savedUsernames.first ?? "NO USER"
        
        if username == "NO USER" {
            return Timeline(entries: [SimpleEntry.placeholder], policy: .after(Date().addingTimeInterval(3600)))
        }
        
        
        if let calendar = viewModel.getUserCalendar(for: username) {
            let contributions = LeetCode.UserCalendar.DailyContribution.parse(from: calendar.submissionCalendar)
            let entry = SimpleEntry(date: Date(), username: username, contributions: contributions)
            
            
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
            
            
            Task {
                do {
                    
                    let freshCalendarData = try await fetchCalendarJSONData(for: username)
                    
                    
                    let storageService = LeetCodeJSONStorageService()
                    storageService.saveCalendarJSONResponse(freshCalendarData, forUsername: username)
                    
                    
                    WidgetCenter.shared.reloadTimelines(ofKind: "kenWidget")
                } catch {
                    
                }
            }
            
            return timeline
        }
        
        
        do {
            let calendarData = try await fetchCalendarJSONData(for: username)
            
            
            let storageService = LeetCodeJSONStorageService()
            storageService.saveCalendarJSONResponse(calendarData, forUsername: username)
            
            
            if let calendar = storageService.parseUserCalendar(from: calendarData) {
                let contributions = LeetCode.UserCalendar.DailyContribution.parse(from: calendar.submissionCalendar)
                let entry = SimpleEntry(date: Date(), username: username, contributions: contributions)
                
                return Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
            }
        } catch {
            
        }
        
        return Timeline(entries: [SimpleEntry.placeholder], policy: .after(Date().addingTimeInterval(3600)))
    }
    
    
    private func fetchCalendarJSONData(for username: String) async throws -> Data {
        let query = """
        query userProfileCalendar($username: String!, $year: Int) {
            matchedUser(username: $username) {
                userCalendar(year: $year) {
                    activeYears
                    streak
                    totalActiveDays
                    dccBadges {
                        timestamp
                        badge {
                            name
                            icon
                        }
                    }
                    submissionCalendar
                }
            }
        }
        """
        
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
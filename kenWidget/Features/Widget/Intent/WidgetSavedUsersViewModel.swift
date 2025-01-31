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
    
    init() {
        loadSavedUsernames()
    }
    
    func loadSavedUsernames() {
        if let usernames = UserDefaults(suiteName: AppGroup)!.stringArray(forKey: userDefaultsKey) {
            savedUsernames = usernames
        }
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
        return SimpleEntry(date: Date(), username: viewModel.savedUsernames.first ?? "NO USER", contributions: [])
    }

    func timeline(for configuration: SelectUserIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let username = configuration.username ?? viewModel.savedUsernames.first ?? "NO USER"
        
        if username == "NO USER" {
            return Timeline(entries: [SimpleEntry.placeholder], policy: .after(Date().addingTimeInterval(3600)))
        }

        do {
            let calendar = try await LeetCode.getUserCalendar(for: username, queue: .global()).value
            let contributions = LeetCode.UserCalendar.DailyContribution.parse(from: calendar.submissionCalendar)
            let entry = SimpleEntry(date: Date(), username: username, contributions: contributions)
            return Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
        } catch {
            return Timeline(entries: [SimpleEntry.placeholder], policy: .after(Date().addingTimeInterval(3600)))
        }
    }
}

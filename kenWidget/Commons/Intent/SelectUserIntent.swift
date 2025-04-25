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

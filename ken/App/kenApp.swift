//
//  kenApp.swift
//  ken
//
//  Created by Lakshay Gupta on 24/01/25.
//

import SwiftUI
@main
struct KenApp: App {
    @StateObject private var leetCodeVM = LeetCodeViewModel()
    @StateObject private var savedUsersVM = SavedUsersViewModel()
    @AppStorage("has_completed_onboarding") private var hasCompletedOnboarding = false
    @State private var deepLinkedUsername: String?

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                SplashScreenView(hasCompletedOnboarding: $hasCompletedOnboarding, savedUsersVM: savedUsersVM)
                    .navigationDestination(isPresented: Binding(
                        get: { deepLinkedUsername != nil },
                        set: { if !$0 { deepLinkedUsername = nil } }
                    )) {
                        if let username = deepLinkedUsername {
                            UserDetailView(username: username)
                        }
                    }
            }
            .environmentObject(leetCodeVM)
            .environmentObject(savedUsersVM)
            .onOpenURL { url in
                handleDeepLink(url: url)
            }
        }
    }

    private func handleDeepLink(url: URL) {
        if url.scheme == "leetcode",
           url.host == "user",
           let username = url.pathComponents.last,
           !username.isEmpty {
            deepLinkedUsername = username
        }
    }
}


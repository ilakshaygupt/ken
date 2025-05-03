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
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView(hasCompletedOnboarding: $hasCompletedOnboarding, savedUsersVM: savedUsersVM)
                .environmentObject(leetCodeVM)
                .environmentObject(savedUsersVM)
        }
    }
}

//
//  kenApp.swift
//  ken
//
//  Created by Lakshay Gupta on 24/01/25.
//

import SwiftUI

@main
struct kenApp: App {
    @StateObject private var savedUsersVM = SavedUsersViewModel()
    @AppStorage("has_completed_onboarding") private var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding && savedUsersVM.hasPrimaryUsername() {
                ContentView()
                    .environmentObject(savedUsersVM)
            } else {
                OnboardingView(savedUsersVM: savedUsersVM)
            }
        }
    }
}

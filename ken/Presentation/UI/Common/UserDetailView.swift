//
//  UserDetailView.swift
//  ken
//
//  Created by Lakshay Gupta on 24/04/25.
//

import SwiftUI

struct UserDetailView: View {
    let username: String
    @EnvironmentObject private var leetCodeVM: LeetCodeViewModel
    @State private var hasLoadedData = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: UIConstants.spacingLarge) {
                VStack(alignment: .leading, spacing: UIConstants.spacingSmall) {
                    Text(username)
                        .font(UIConstants.titleFont)
                        .fontWeight(.bold)
                    
                    if let stats = leetCodeVM.userStats[username] {
                        VStack(alignment: .leading, spacing: UIConstants.itemSpacing) {
                            Text("Statistics")
                                .font(UIConstants.title2Font)
                                .fontWeight(.bold)
                            
                            StatsView(stats: stats)
                        }
                        .modifier(AppTheme.shared.sectionStyle(in: colorScheme))
                        .modifier(AppTheme.shared.cardStyle(in: colorScheme))
                    }
                    
                    if let calendar = leetCodeVM.userCalendars[username] {
                        VStack(alignment: .leading, spacing: UIConstants.itemSpacing) {
                            Text("Activity")
                                .font(UIConstants.title2Font)
                                .fontWeight(.bold)
                            
                            CalendarView(calendar: calendar)
                        }
                        .modifier(AppTheme.shared.sectionStyle(in: colorScheme))
                        .modifier(AppTheme.shared.cardStyle(in: colorScheme))
                    }
                }
                .padding(UIConstants.padding)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .background(AppTheme.shared.backgroundColor(in: colorScheme))
        }
        .onAppear {
            // Data should already be loaded from app startup
            // Only fetch if somehow missing
            if !hasLoadedData {
                hasLoadedData = true
                Task {
                    if leetCodeVM.userStats[username] == nil || leetCodeVM.userCalendars[username] == nil {
                        async let dataFetch = leetCodeVM.fetchData(for: username)
                        async let profileFetch = leetCodeVM.fetchUserProfile(for: username)
                        let _ = await (dataFetch, profileFetch)
                    }
                }
            }
        }
    }
}

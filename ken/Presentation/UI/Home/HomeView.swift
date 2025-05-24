//
//  HomeView.swift
//  ken
//
//  Created by Lakshay on 25/07/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var leetCodeVM : LeetCodeViewModel
    @ObservedObject var savedUsersVM: SavedUsersViewModel
    @State private var isRefreshing = false
    @State private var animate = false
    @State private var showingDetailView = false
    @State private var expandedCard: HomeCardType?
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var backgroundColor: Color {
        AppTheme.shared.backgroundColor(in: colorScheme)
    }
    
    private var cardBackgroundColor: Color {
        AppTheme.shared.cardBackgroundColor(in: colorScheme)
    }
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            if let primaryUsername = savedUsersVM.primaryUsername {
                ScrollView {
                    VStack(spacing: 24) {
                        UserProfileHeaderView(
                            username: primaryUsername,
                            userProfile: leetCodeVM.userProfiles[primaryUsername],
                            userStats: leetCodeVM.userStats[primaryUsername],
                            animate: animate
                        )
                        .padding(.top)
                        
                        if leetCodeVM.isLoading && !isRefreshing {
                            LoadingView(message: "Loading your LeetCode data...")
                                .padding(.horizontal, 20)
                        } else if let stats = leetCodeVM.userStats[primaryUsername],
                                  let calendar = leetCodeVM.userCalendars[primaryUsername] {
                            
                            VStack(spacing: 24) {
                                CardView(
                                    title: "Statistics",
                                    systemImage: "chart.bar",
                                    gradient: [.blue, .blue.opacity(0.7)],
                                    animate: animate
                                ) {
                                    StatisticsContentView(stats: stats)
                                        .padding()
                                }
                                
                                CardView(
                                    title: "Activity Graph",
                                    systemImage: "calendar",
                                    gradient: [.indigo, .indigo.opacity(0.7)],
                                    animate: animate
                                ) {
                                    ContributionsView(
                                        contributions: calendar.contributions,
                                        monthsToShow: 12
                                    )
                                    .padding()
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        if let error = leetCodeVM.error {
                            ErrorView(message: error.localizedDescription)
                                .padding(.horizontal, 20)
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.bottom)
                }
                .refreshable {
                    await refreshData(username: primaryUsername)
                }
            } else {
                NoPrimaryUserView()
                    .padding(.horizontal, 20)
            }
        }
        .onAppear {
            startAnimations()

        }
        .sheet(isPresented: $showingDetailView) {
            if let expandedType = expandedCard,
               let primaryUsername = savedUsersVM.primaryUsername,
               let stats = leetCodeVM.userStats[primaryUsername],
               let calendar = leetCodeVM.userCalendars[primaryUsername] {
                
                DetailCardView(cardType: expandedType, stats: stats, calendar: calendar)
            }
        }
    }
    
    private func startAnimations() {
        animate = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animate = true
            }
        }
    }
    private func refreshData(username: String) async {
        isRefreshing = true
        
        let success = await leetCodeVM.fetchData(for: username, forceRefresh: true)
        
        await MainActor.run {
            isRefreshing = false
        }
        
        if !success {
            print("Failed to refresh data for \(username)")
        }
    }
}







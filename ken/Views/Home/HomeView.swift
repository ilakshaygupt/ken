//
//  HomeView.swift
//  ken
//
//  Created by Claude on 25/07/25.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var leetCodeVM: LeetCodeViewModel
    @ObservedObject var savedUsersVM: SavedUsersViewModel
    @State private var isRefreshing = false
    @State private var animate = false
    @State private var showingDetailView = false
    @State private var expandedCard: HomeCardType?
    
    @Environment(\.colorScheme) private var colorScheme
    
    // Get background colors from AppTheme
    private var backgroundColor: Color {
        AppTheme.shared.backgroundColor(in: colorScheme)
    }
    
    private var cardBackgroundColor: Color {
        AppTheme.shared.cardBackgroundColor(in: colorScheme)
    }
    
    // Updated color scheme for consistency
    struct CardTheme {
        let primaryGradient: [Color]
        let iconBackground: Color
        let cardBackground: Color
        
        static let stats = CardTheme(
            primaryGradient: [Color.blue, Color.blue.opacity(0.7)],
            iconBackground: .blue,
            cardBackground: Color("CardBackground")
        )
        
        static let yearly = CardTheme(
            primaryGradient: [Color.orange, Color.orange.opacity(0.7)],
            iconBackground: .orange,
            cardBackground: Color("CardBackground")
        )
        
        static let calendar = CardTheme(
            primaryGradient: [Color.indigo, Color.indigo.opacity(0.7)],
            iconBackground: .indigo,
            cardBackground: Color("CardBackground")
        )
    }
    
    enum HomeCardType: String, CaseIterable {
        case stats = "Statistics"
        case graph = "Activity Graph"
        
        var systemImage: String {
            switch self {
            case .stats: return "chart.bar"
            case .graph: return "calendar"
            }
        }
        
        var gradient: [Color] {
            switch self {
            case .stats: return [Color.blue, Color.blue.opacity(0.7)]
            case .graph: return [Color.indigo, Color.indigo.opacity(0.7)]
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Background - using hex color for dark mode
            backgroundColor
                .ignoresSafeArea()
            
            if let primaryUsername = savedUsersVM.primaryUsername {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerView(username: primaryUsername)
                            .padding(.top)
                        
                        if leetCodeVM.isLoading && !isRefreshing {
                            loadingView()
                                .padding(.horizontal, 20)
                        } else if let stats = leetCodeVM.userStats[primaryUsername],
                                  let calendar = leetCodeVM.userCalendars[primaryUsername] {
                            
                            // Display only two sections: Stats and Graph
                            VStack(spacing: 24) {
                                // Stats Section
                                sectionView(title: "Statistics", systemImage: "chart.bar", gradient: [.blue, .blue.opacity(0.7)]) {
                                    StatsCardView(stats: stats)
                                        .padding()
                                }
                                
                                // Graph Section - simplified to always show 12 months
                                sectionView(title: "Activity Graph", systemImage: "calendar", gradient: [.indigo, .indigo.opacity(0.7)]) {
                                    VStack(spacing: 12) {
                                        HStack {
                                            Text("Last 12 months")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            
                                            Spacer()
                                        }
                                        .padding(.horizontal)
                                        .padding(.top, 8)
                                        
                                        ContributionGraphView(
                                            contributions: calendar.contributions,
                                            monthsToShow: 12
                                        )
                                        .padding(.bottom, 8)
                                    }
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
                .overlay(refreshButton)
            } else {
                noPrimaryUserView()
                    .padding(.horizontal, 20)
            }
        }
        .onAppear {
            startAnimations()
            if let primaryUsername = savedUsersVM.primaryUsername {
                leetCodeVM.fetchData(for: primaryUsername)
            }
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
    
    // MARK: - Helper Views
    
    private func sectionView<Content: View>(title: String, systemImage: String, gradient: [Color], @ViewBuilder content: @escaping () -> Content) -> some View {
        VStack(spacing: 0) {
            // Section Header
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 30, height: 30)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: gradient),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            // Section Content
            content()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(cardBackgroundColor)
                )
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(cardBackgroundColor)
        )
        .opacity(animate ? 1 : 0)
        .offset(y: animate ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: animate)
    }
    
    // MARK: - Extracted Views
    
    // Extracted refresh button to simplify view hierarchy
    private var refreshButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    if let primaryUsername = savedUsersVM.primaryUsername {
                        Task {
                            await refreshData(username: primaryUsername)
                        }
                    }
                }) {
                    Image(systemName: isRefreshing ? "arrow.triangle.2.circlepath" : "arrow.clockwise")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(createRefreshButtonBackground())
                        .clipShape(Circle())
                        .rotationEffect(Angle(degrees: isRefreshing ? 360 : 0))
                        .animation(isRefreshing ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isRefreshing)
                }
                .padding(24)

            }
        }
    }
    
    private func createRefreshButtonBackground() -> some View {
        let colors: [Color] = [.blue, .purple]
        
        return LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private func headerView(username: String) -> some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome back!")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .opacity(animate ? 1 : 0)
                        .offset(y: animate ? 0 : -20)
                    
                    Text(username)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                        .opacity(animate ? 1 : 0)
                        .scaleEffect(animate ? 1 : 0.8)
                }
                
                Spacer()
                
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                    .opacity(animate ? 1 : 0)
                    .scaleEffect(animate ? 1 : 0.8)
                    .offset(x: animate ? 0 : 20)
            }
            
            if let stats = leetCodeVM.userStats[username] {
                Divider()
                    .opacity(animate ? 1 : 0)
                
                HStack(spacing: 20) {   
                    // Problems Solved
                    statItem(
                        value: "\(stats.totalSolved)",
                        label: "Problems",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                    
                    Divider()
                        .frame(height: 40)
                    
                    // Rating
//                    statItem(
//                        value: "\(stats.contestRating)",
//                        label: "Rating",
//                        icon: "star.fill",
//                        color: .yellow
//                    )
//                    
//                    Divider()
//                        .frame(height: 40)
//                    
//                    // Rank
//                    statItem(
//                        value: "\(stats.contestGlobalRanking)",
//                        label: "Rank",
//                        icon: "trophy.fill",
//                        color: .orange
//                    )
                }
                .padding(.vertical, 8)
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : 20)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(cardBackgroundColor)
                
        )
        .padding(.horizontal, 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: animate)
    }
    
    private func statItem(value: String, label: String, icon: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 20))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func loadingView() -> some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            
            Text("Loading your LeetCode data...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 250)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(cardBackgroundColor)
                
        )
    }
    
    private func noPrimaryUserView() -> some View {
        VStack(spacing: 24) {
            Image(systemName: "person.fill.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.blue.opacity(0.7))
            
            Text("No Primary Username Set")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Please set a primary username in your profile settings.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(cardBackgroundColor)
                
        )
    }
    
    private func startAnimations() {
        // Reset animation state
        animate = false
        
        // Slight delay before animations start
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animate = true
            }
        }
    }
    
    private func refreshData(username: String) async {
        isRefreshing = true
        
        // Simulate network delay for animation
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        leetCodeVM.fetchData(for: username, forceRefresh: true)
        
        // Add slight delay after refreshing completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isRefreshing = false
        }
    }
}

// MARK: - Supporting Views

struct DetailCardView: View {
    let cardType: HomeView.HomeCardType
    let stats: UserStats
    let calendar: UserCalendar
    @Environment(\.dismiss) private var dismiss
    @State private var animateContent = false
    @Environment(\.colorScheme) private var colorScheme
    
    private var backgroundColor: Color {
        AppTheme.shared.backgroundColor(in: colorScheme)
    }
    
    private var cardBackgroundColor: Color {
        AppTheme.shared.cardBackgroundColor(in: colorScheme)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    switch cardType {
                    case .stats:
                        StatsCardView(stats: stats)
                            .padding(.horizontal)
                    case .graph:
                        VStack(spacing: 12) {
                            ContributionGraphView(
                                contributions: calendar.contributions,
                                monthsToShow: 24
                            )
                            
                            // Additional stats could go here
                            Text("Total Contributions: \(calendar.contributions.count)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding()
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 30)
            }
            .navigationTitle(cardType.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .background(backgroundColor)
            .onAppear {
                withAnimation(.easeOut(duration: 0.3)) {
                    animateContent = true
                }
            }
        }
        .background(backgroundColor)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .brightness(configuration.isPressed ? -0.05 : 0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}


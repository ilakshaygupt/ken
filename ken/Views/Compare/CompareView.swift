//
//  CompareView.swift
//  ken
//
//  Created by Claude on 25/07/25.
//

import SwiftUI

struct CompareView: View {
    @ObservedObject var leetCodeVM: LeetCodeViewModel
    @ObservedObject var savedUsersVM: SavedUsersViewModel
    @State private var selectedUsername: String?
    @Environment(\.colorScheme) private var colorScheme
    private var backgroundColor: Color {
        AppTheme.shared.backgroundColor(in: colorScheme)
    }

    
    var body: some View {
        ZStack{
            backgroundColor
                .ignoresSafeArea()
            
            VStack {
                if let primaryUsername = savedUsersVM.primaryUsername {
                    if let userProfile = leetCodeVM.userProfiles[primaryUsername] {
                        VStack(alignment: .center) {
                            if let avatarUrl = userProfile.userAvatar, !avatarUrl.isEmpty {
                                AsyncImage(url: URL(string: avatarUrl)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                }
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.gray)
                            }
                            
                            Text(userProfile.realName ?? primaryUsername)
                                .font(.headline)
                            
                            if let jobTitle = userProfile.jobTitle, !jobTitle.isEmpty {
                                Text(jobTitle)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            if let company = userProfile.company, !company.isEmpty {
                                Text(company)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    
                    if savedUsersVM.savedUsernames.count > 1 {
                        VStack {
                            Text("Compare with:")
                                .font(.headline)
                                .padding(.top)
                            
                            Menu {
                                ForEach(savedUsersVM.savedUsernames.filter { $0 != primaryUsername }, id: \.self) { username in
                                    Button(username) {
                                        selectedUsername = username
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedUsername ?? "Select user")
                                    Image(systemName: "chevron.down")
                                }
                                .foregroundColor(.primary)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(AppTheme.shared.cardBackgroundColor(in: colorScheme))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.bottom, 10)
                        
                        if let selectedUsername = selectedUsername,
                           let primaryStats = leetCodeVM.userStats[primaryUsername],
                           let compareStats = leetCodeVM.userStats[selectedUsername] {
                            
                            ScrollView {
                                ComparisonView(
                                    primaryUsername: primaryUsername, 
                                    compareUsername: selectedUsername,
                                    primaryStats: primaryStats,
                                    compareStats: compareStats,
                                    leetCodeVM: leetCodeVM
                                )
                            }
                        } else {
                            VStack {
                                Image(systemName: "person.2")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                    .padding()
                                    
                                Text("Select a user to compare with \(primaryUsername)")
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    } else {
                        VStack {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                                .padding()
                                
                            Text("Add more users to compare with \(primaryUsername)")
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                
                            NavigationLink(destination: SavedUsersView(savedUsersVM: savedUsersVM, leetCodeVM: leetCodeVM)) {
                                Text("Add Users")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 30)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .padding(.top, 20)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                            .padding()
                            
                        Text("Primary username not set")
                            .font(.headline)
                            .foregroundColor(.red)
                            
                        Text("Please set a primary user in settings")
                            .foregroundColor(.gray)
                            .padding(.top, 5)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .onAppear {
            
            if selectedUsername == nil,
               let primaryUsername = savedUsersVM.primaryUsername,
               let firstOtherUser = savedUsersVM.savedUsernames.first(where: { $0 != primaryUsername }) {
                selectedUsername = firstOtherUser
            }
            
            // Load data for all saved users
            for username in savedUsersVM.savedUsernames {
                leetCodeVM.fetchData(for: username)
            }
            
            // Load user profiles
            for username in savedUsersVM.savedUsernames {
                leetCodeVM.fetchUserProfile(for: username)
            }
        }
        .background(AppTheme.shared.backgroundColor(in: colorScheme))
    }
}

struct ComparisonView: View {
    let primaryUsername: String
    let compareUsername: String
    let primaryStats: UserStats
    let compareStats: UserStats
    @ObservedObject var leetCodeVM: LeetCodeViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    // Define consistent colors for primary and comparison users
    private let primaryColor = Color.blue
    private let compareColor = Color.green
    private let neutralColor = Color.gray
    
    var body: some View {
        VStack(spacing: 20) {
            header
            statsComparison
            contributionGraphComparison
            progressComparison
            difficultyBarChart
        }
        .padding()
    }
    
    private var header: some View {
        HStack(spacing: 15) {
            VStack(alignment: .center) {
                Text(primaryUsername)
                    .font(.headline)
                    .foregroundColor(primaryColor)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            
            Text("VS")
                .font(.headline)
                .foregroundColor(neutralColor)
                .padding(.horizontal, 5)
            
            VStack(alignment: .center) {
                Text(compareUsername)
                    .font(.headline)
                    .foregroundColor(compareColor)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(AppTheme.shared.cardBackgroundColor(in: colorScheme))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var statsComparison: some View {
        VStack(spacing: 18) {
            Text("Problems Solved")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            comparisonRow(label: "Total", value1: primaryStats.totalSolved, value2: compareStats.totalSolved)
            Divider()
            comparisonRow(label: "Easy", value1: primaryStats.easySolved, value2: compareStats.easySolved)
            Divider()
            comparisonRow(label: "Medium", value1: primaryStats.mediumSolved, value2: compareStats.mediumSolved)
            Divider()
            comparisonRow(label: "Hard", value1: primaryStats.hardSolved, value2: compareStats.hardSolved)
        }
        .padding()
        .background(AppTheme.shared.cardBackgroundColor(in: colorScheme))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func comparisonRow(label: String, value1: Int, value2: Int) -> some View {
        HStack {
            Text(label)
                .frame(width: 70, alignment: .leading)
                .foregroundColor(.primary.opacity(0.8))
            
            Text("\(value1)")
                .foregroundColor(primaryColor)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
            
            if value1 > value2 {
                Image(systemName: "arrow.right")
                    .foregroundColor(primaryColor)
                    .font(.system(size: 14, weight: .bold))
            } else if value2 > value1 {
                Image(systemName: "arrow.right")
                    .foregroundColor(compareColor)
                    .font(.system(size: 14, weight: .bold))
            } else {
                Image(systemName: "equal")
                    .foregroundColor(neutralColor)
                    .font(.system(size: 14, weight: .bold))
            }
            
            Text("\(value2)")
                .foregroundColor(compareColor)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
        }
    }
    
    private var contributionGraphComparison: some View {
        VStack(spacing: 16) {
            Text("Contribution Activity")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                contributionSection(username: primaryUsername, color: primaryColor)
                
                Divider()
                    .padding(.vertical, 4)
                
                contributionSection(username: compareUsername, color: compareColor)
            }
        }
        .padding()
        .background(AppTheme.shared.cardBackgroundColor(in: colorScheme))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func contributionSection(username: String, color: Color) -> some View {
        let calendar = leetCodeVM.userCalendars[username]
        let contributions = calendar?.contributions ?? []
        
        return VStack(alignment: .leading, spacing: 8) {
            VStack {
                Text(username)
                    .fontWeight(.medium)
                    .foregroundColor(color)
                
                if let calendar = calendar {
                    Spacer()
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .center, spacing: 0) {
                            Text("\(calendar.streak)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(color)
                            Text("streak")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .center, spacing: 0) {
                            Text("\(calendar.totalActiveDays)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(color)
                            Text("active days")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            if contributions.isEmpty {
                Text("No contribution data available")
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .frame(height: 100)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(color.opacity(0.05))
                    )
            } else {
                ContributionGridView(
                    contributions: contributions,
                    hoveredContribution: .constant(nil),
                    monthsToShow: 11
                )
                .environment(\.contributionColorScheme, color == primaryColor ? .blue : .green)
                .padding(.vertical, 4)
            }
        }
    }
    
    private var progressComparison: some View {
        VStack(spacing: 12) {
            Text("Progress Comparison")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                progressCircle(
                    username: primaryUsername,
                    total: primaryStats.totalSolved,
                    color: primaryColor
                )
                
                progressCircle(
                    username: compareUsername,
                    total: compareStats.totalSolved,
                    color: compareColor
                )
            }
        }
        .padding()
        .background(AppTheme.shared.cardBackgroundColor(in: colorScheme))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func progressCircle(username: String, total: Int, color: Color) -> some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 10)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: min(CGFloat(total) / 2200.0, 1.0))
                    .stroke(color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: total)
                
                VStack {
                    Text("\(total)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                    
                    Text("solved")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(username)
                .font(.caption)
                .foregroundColor(color)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: 120)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var difficultyBarChart: some View {
        VStack(spacing: 12) {
            Text("Problem Difficulty Breakdown")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(alignment: .bottom, spacing: 8) {
                difficultyBar(label: "Easy", value1: primaryStats.easySolved, value2: compareStats.easySolved, maxValue: 600)
                difficultyBar(label: "Medium", value1: primaryStats.mediumSolved, value2: compareStats.mediumSolved, maxValue: 1200)
                difficultyBar(label: "Hard", value1: primaryStats.hardSolved, value2: compareStats.hardSolved, maxValue: 500)
            }
            .padding(.top, 8)
            
            HStack {
                Circle()
                    .fill(primaryColor)
                    .frame(width: 10, height: 10)
                Text(primaryUsername)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Circle()
                    .fill(compareColor)
                    .frame(width: 10, height: 10)
                Text(compareUsername)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(AppTheme.shared.cardBackgroundColor(in: colorScheme))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func difficultyBar(label: String, value1: Int, value2: Int, maxValue: Int) -> some View {
        HStack(spacing: 2) {
            VStack(spacing: 8) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 1) {
                    // Primary user bar
                    ZStack(alignment: .bottom) {
                        Rectangle()
                            .fill(primaryColor.opacity(0.3))
                            .frame(width: 30, height: 150)
                        
                        Rectangle()
                            .fill(primaryColor)
                            .frame(width: 30, height: min(150 * CGFloat(value1) / CGFloat(maxValue), 150))
                            .animation(.easeInOut(duration: 0.8), value: value1)
                    }
                    .cornerRadius(6)
                    
                    // Compare user bar
                    ZStack(alignment: .bottom) {
                        Rectangle()
                            .fill(compareColor.opacity(0.3))
                            .frame(width: 30, height: 150)
                        
                        Rectangle()
                            .fill(compareColor)
                            .frame(width: 30, height: min(150 * CGFloat(value2) / CGFloat(maxValue), 150))
                            .animation(.easeInOut(duration: 0.8), value: value2)
                    }
                    .cornerRadius(6)
                }
                
                HStack(spacing: 10) {
                    Text("\(value1)")
                        .font(.caption)
                        .foregroundColor(primaryColor)
                    
                    Text("\(value2)")
                        .font(.caption)
                        .foregroundColor(compareColor)
                }
            }
        }
    }
} 

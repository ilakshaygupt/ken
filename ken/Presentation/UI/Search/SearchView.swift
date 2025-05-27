//
//  UIConstants.swift
//  ken
//
//  Created by Lakshay Gupta on 09/05/25.
//


import SwiftUI
import Foundation
import Combine

struct SearchView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SearchViewModel
    @State private var hoveredContribution: DailyContribution?
    
    init(viewModel: SearchViewModel? = nil) {
        let vm = viewModel ?? SearchViewModel()
        _viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: UIConstants.spacing) {
                searchBarView
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 200)
                } else {
                    contentView
                }
                
                if let error = viewModel.error {
                    errorView(message: error.localizedDescription)
                }
            }
            .padding(.vertical, UIConstants.spacing)
        }
        .navigationTitle("Search User")
        .navigationBarTitleDisplayMode(.inline)
        .background(AppTheme.shared.backgroundColor(in: colorScheme))
    }
    
    private var searchBarView: some View {
        HStack {
            TextField("Enter LeetCode username", text: $viewModel.username)
                .padding(.horizontal, UIConstants.cardPadding)
                .frame(height: UIConstants.searchBarHeight)
                .background(AppTheme.shared.cardBackgroundColor(in: colorScheme))
                .cornerRadius(UIConstants.cornerRadius)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            Button(action: viewModel.searchUser) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white)
                    .frame(width: UIConstants.searchBarHeight, height: UIConstants.searchBarHeight)
                    .background(Color.accentColor)
                    .cornerRadius(UIConstants.cornerRadius)
            }
            .disabled(viewModel.username.isEmpty || viewModel.isLoading)
        }
        .padding(.horizontal, UIConstants.cardPadding)
    }
    
    private var contentView: some View {
        VStack(spacing: UIConstants.spacing) {
            if let profile = viewModel.userProfile {
                profileHeaderView(profile: profile)
            }
            
            if let stats = viewModel.userStats {
                statsView(stats: stats)
            }
            
            if let calendar = viewModel.userCalendar {
                enhancedCalendarView(calendar: calendar)
            }
        }
    }
    
    private func profileHeaderView(profile: UserProfile) -> some View {
        VStack(spacing: UIConstants.itemSpacing) {
            if let avatarUrl = profile.userAvatar {
                AsyncImage(url: URL(string: avatarUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                }
                .frame(width: UIConstants.avatarSize, height: UIConstants.avatarSize)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.accentColor, lineWidth: 2)
                )
            }
            
            VStack(spacing: 4) {
                Text(profile.realName ?? profile.username)
                    .font(.title2)
                    .bold()
                
                Text("@\(profile.username)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let aboutMe = profile.aboutMe, !aboutMe.isEmpty {
                Text(aboutMe)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            HStack(spacing: UIConstants.itemSpacing) {
                if let company = profile.company {
                    infoLabel(title: company, systemImage: "building.2")
                }
                if let school = profile.school {
                    infoLabel(title: school, systemImage: "graduationcap")
                }
            }
        }
        .padding(UIConstants.cardPadding)
        .background(AppTheme.shared.cardBackgroundColor(in: colorScheme))
        .cornerRadius(UIConstants.cornerRadius)
        .shadow(color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.2),
                radius: 4, x: 0, y: 2)
        .padding(.horizontal, UIConstants.cardPadding)
    }
    
    private func infoLabel(title: String, systemImage: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
                .font(.system(size: 12))
            Text(title)
                .font(.caption)
        }
        .foregroundColor(.secondary)
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(UIConstants.cornerRadius / 2)
    }
    
    private func statsView(stats: UserStats) -> some View {
        VStack(alignment: .leading, spacing: UIConstants.itemSpacing) {
            Text("Problem Solving Stats")
                .font(.headline)
                .padding(.bottom, 4)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: UIConstants.spacing),
                GridItem(.flexible(), spacing: UIConstants.spacing)
            ], spacing: UIConstants.spacing) {
                statItem(value: "\(stats.totalSolved)", label: "Total Solved", color: .green)
                statItem(value: "\(stats.easySolved)/\(stats.easyTotal)", label: "Easy", color: .green)
                statItem(value: "\(stats.mediumSolved)/\(stats.mediumTotal)", label: "Medium", color: .orange)
                statItem(value: "\(stats.hardSolved)/\(stats.hardTotal)", label: "Hard", color: .red)
            }
            
            if let rank = stats.ranking {
                Text("Global Rank: #\(rank)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
        }
        .padding(UIConstants.cardPadding)
        .background(AppTheme.shared.cardBackgroundColor(in: colorScheme))
        .cornerRadius(UIConstants.cornerRadius)
        .shadow(color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.2),
                radius: 4, x: 0, y: 2)
        .padding(.horizontal, UIConstants.cardPadding)
    }
    
    private func statItem(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(UIConstants.cornerRadius)
    }
    
    private func enhancedCalendarView(calendar: UserCalendar) -> some View {
        VStack(alignment: .leading, spacing: UIConstants.itemSpacing) {
            Text("Activity Calendar")
                .font(.headline)
                .padding(.bottom, 4)
            
            let contributions = DailyContribution.parse(from: calendar.submissionCalendar)
            
            ContributionGridView(
                contributions: contributions,
                hoveredContribution: $hoveredContribution,
                monthsToShow: 6
            )
            .environment(\.contributionColorScheme, .green)
            .frame(height: 150)
            
            if let hovered = hoveredContribution {
                HStack {
                    let dateFormatter = DateFormatter()
                    Text("\(dateFormatter.string(from: hovered.date)): \(hovered.count) submissions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
            
            HStack {
                Text("Total Active Days: \(calendar.totalActiveDays)")
                Spacer()
                Text("Current Streak: \(calendar.streak)")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.top, 4)
        }
        .padding(UIConstants.cardPadding)
        .background(AppTheme.shared.cardBackgroundColor(in: colorScheme))
        .cornerRadius(UIConstants.cornerRadius)
        .shadow(color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.2),
                radius: 4, x: 0, y: 2)
        .padding(.horizontal, UIConstants.cardPadding)
    }
    
    private func errorView(message: String) -> some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
                .padding(.bottom, 8)
            
            Text("Error")
                .font(.headline)
                .padding(.bottom, 4)
            
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding(UIConstants.cardPadding)
        .background(Color(.systemBackground))
        .cornerRadius(UIConstants.cornerRadius)
        .shadow(radius: 2)
        .padding(.horizontal, UIConstants.cardPadding)
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SearchView()
        }
    }
}

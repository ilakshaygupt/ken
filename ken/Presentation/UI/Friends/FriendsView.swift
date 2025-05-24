//
//  FriendsView.swift
//  ken
//
//  Created by Lakshay on 25/07/25.
//
import SwiftUI

struct FriendsView: View {
    @EnvironmentObject private var leetCodeVM : LeetCodeViewModel
    @ObservedObject var savedUsersVM: SavedUsersViewModel
    @State private var showingAddSheet = false
    @State private var newUsername = ""
    @Environment(\.colorScheme) private var colorScheme
    @State private var searchText = ""
    @State private var sortOption: SortOption = .name
    @State private var isRefreshing = false
    
    enum SortOption: String, CaseIterable {
        case name = "Name"
        case rank = "Rank"
        case solved = "Solved"
    }
    
    private var filteredUsernames: [String] {
        if searchText.isEmpty {
            return savedUsersVM.savedUsernames
        }
        return savedUsersVM.savedUsernames.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    private var sortedUsernames: [String] {
        let filtered = filteredUsernames
        
        switch sortOption {
        case .name:
            return filtered.sorted()
            
        case .rank:
            return filtered.sorted { username1, username2 in
                let rank1 = leetCodeVM.userStats[username1]?.ranking ?? Int.max
                let rank2 = leetCodeVM.userStats[username2]?.ranking ?? Int.max
                return rank1 < rank2
            }
            
        case .solved:
            return filtered.sorted { username1, username2 in
                let solved1 = leetCodeVM.userStats[username1]?.totalSolved ?? 0
                let solved2 = leetCodeVM.userStats[username2]?.totalSolved ?? 0
                return solved1 > solved2
            }
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if savedUsersVM.savedUsernames.isEmpty {
                    emptyStateView
                } else {
                    friendsList
                }
            }
            .background(AppTheme.shared.backgroundColor(in: colorScheme))
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            showingAddSheet = true
                        }
                    }) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
                            )
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                    .scaleEffect(showingAddSheet ? 0.95 : 1.0)
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search friends")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                sortMenu
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddFriendView(
                leetCodeVM: leetCodeVM,
                savedUsersVM: savedUsersVM,
                isPresented: $showingAddSheet,
                username: $newUsername
            )
            .interactiveDismissDisabled(false)
        }
    }
    
    private var sortMenu: some View {
        Menu {
            ForEach(SortOption.allCases, id: \.self) { option in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        sortOption = option
                    }
                }) {
                    HStack {
                        Text("Sort by \(option.rawValue)")
                        Spacer()
                        Image(systemName: sortIcon(for: option))
                        if sortOption == option {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down.circle")
                .font(.system(size: 16))
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
                .frame(height: 20)
            
            Image(systemName: "person.3.fill")
                .font(.system(size: 70))
                .foregroundColor(.blue.opacity(0.7))
                .padding(.bottom, 10)
            
            Text("No Friends Added")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Add friends to compare progress and track their LeetCode journey")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 10)
            
            Button(action: { showingAddSheet = true }) {
                HStack {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 16))
                    Text("Add Friend")
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(color: Color.blue.opacity(0.2), radius: 4, x: 0, y: 2)
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var friendsList: some View {
        List {
            ForEach(sortedUsernames, id: \.self) { username in
                NavigationLink(destination: UserDetailView(username: username)) {
                    FriendRowView(username: username)
                }
                .listRowBackground(AppTheme.shared.cardBackgroundColor(in: colorScheme))
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    if username != savedUsersVM.primaryUsername {
                        Button(role: .destructive) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                savedUsersVM.removeUsername(username)
                            }
                        } label: {
                            Label("Remove", systemImage: "trash")
                        }
                    }
                    
                    Button {
                        Task {
                            await refreshSingleUser(username: username)
                        }
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    .tint(.blue)
                }
                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                    if username != savedUsersVM.primaryUsername {
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                savedUsersVM.setPrimaryUsername(username)
                            }
                        } label: {
                            Label("Set as Primary", systemImage: "star.fill")
                        }
                        .tint(.yellow)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .refreshable {
            await refreshUserData(forceRefresh: true)
        }
    }
    
    private func sortIcon(for option: SortOption) -> String {
        switch option {
        case .name:
            return "textformat"
        case .rank:
            return "trophy"
        case .solved:
            return "checkmark.circle"
        }
    }
    
    @MainActor
    private func refreshUserData(forceRefresh: Bool = false) async {
        guard !isRefreshing else { return }
        
        isRefreshing = true
        defer { isRefreshing = false }
        
        await withTaskGroup(of: Void.self) { group in
            for username in savedUsersVM.savedUsernames {
                group.addTask {
                    await refreshSingleUser(username: username, forceRefresh: forceRefresh)
                }
            }
        }
    }
    
    @MainActor
    private func refreshSingleUser(username: String, forceRefresh: Bool = true) async {
        let success = await leetCodeVM.fetchData(for: username, forceRefresh: forceRefresh)
    }
}

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

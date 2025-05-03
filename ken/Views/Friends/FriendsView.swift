//
//  FriendsView.swift
//  ken
//
//  Created by Claude on 25/07/25.
//

import SwiftUI

struct FriendsView: View {
    @ObservedObject var leetCodeVM: LeetCodeViewModel
    @ObservedObject var savedUsersVM: SavedUsersViewModel
    @State private var showingAddSheet = false
    @State private var newUsername = ""
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    if savedUsersVM.savedUsernames.isEmpty {
                        emptyStateView
                    } else {
                        friendsList
                    }
                }
                .onAppear {
                    for username in savedUsersVM.savedUsernames {
                        leetCodeVM.fetchData(for: username)
                    }
                }
                .background(AppTheme.shared.backgroundColor(in: colorScheme))
                
                // Floating action button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showingAddSheet = true }) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddFriendView(
                    leetCodeVM: leetCodeVM,
                    savedUsersVM: savedUsersVM,
                    isPresented: $showingAddSheet,
                    username: $newUsername
                )
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.7))
                .padding(.bottom, 10)
                
            Text("You haven't added any friends yet")
                .font(.headline)
                .foregroundColor(.primary)
                
            Text("Add friends to compare progress and track their LeetCode journey")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 10)
            
            Button(action: { showingAddSheet = true }) {
                Label("Add Friend", systemImage: "person.badge.plus")
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var friendsList: some View {
        List {
            ForEach(savedUsersVM.savedUsernames, id: \.self) { username in
                NavigationLink(destination: UserDetailView(username: username, leetCodeVM: leetCodeVM)) {
                    HStack {
                        FriendRowView(username: username, leetCodeVM: leetCodeVM)
                        
                        Spacer()
                        
                        if username == savedUsersVM.primaryUsername {
                            PrimaryBadge()
                        } else {
                            MakePrimaryButton(action: {
                                savedUsersVM.changePrimaryUsername(username)
                            })
                        }
                    }
                }
                .swipeActions(edge: .trailing) {
                    if username != savedUsersVM.primaryUsername {
                        Button(role: .destructive) {
                            savedUsersVM.removeUsername(username)
                        } label: {
                            Label("Remove", systemImage: "trash")
                        }
                    }
                    
                    Button {
                        leetCodeVM.fetchData(for: username, forceRefresh: true)
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    .tint(.blue)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

struct FriendRowView: View {
    let username: String
    @ObservedObject var leetCodeVM: LeetCodeViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(username)
                .font(.headline)
                .foregroundColor(.primary)
            
            if let stats = leetCodeVM.userStats[username] {
                HStack(spacing: 16) {
                    StatLabel(
                        count: stats.totalSolved,
                        label: "solved",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                    
//                    StatLabel(
//                        count: stats.ranking,
//                        label: "rank",
//                        icon: "chart.bar.fill",
//                        color: .blue
//                    )
                    
                    if let calendar = leetCodeVM.userCalendars[username] {
                        StatLabel(
                            count: calendar.streak,
                            label: "streak",
                            icon: "flame.fill",
                            color: .orange
                        )
                    }
                }
            } else {
                HStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                        .scaleEffect(0.8)
                    
                    Text("Loading stats...")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct StatLabel: View {
    let count: Int
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 12))
            
            Text("\(count) \(label)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct PrimaryBadge: View {
    var body: some View {
        Text("Primary")
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.blue)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.15))
            .cornerRadius(6)
    }
}

struct MakePrimaryButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Make Primary")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.green)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.15))
                .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AddFriendView: View {
    @ObservedObject var leetCodeVM: LeetCodeViewModel
    @ObservedObject var savedUsersVM: SavedUsersViewModel
    @Binding var isPresented: Bool
    @Binding var username: String
    @State private var isLoading = false
    @State private var errorMessage: String?
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("LeetCode Username", text: $username)
                    .padding()
                    .background(AppTheme.shared.cardBackgroundColor(in: colorScheme))
                    .cornerRadius(8)
                    .disabled(isLoading)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                }
                
                Button(action: addFriend) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Add Friend")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(username.isEmpty || isLoading)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Add Friend")
            .navigationBarItems(
                trailing: Button("Cancel") {
                    isPresented = false
                }
            )
            .background(AppTheme.shared.backgroundColor(in: colorScheme))
        }
    }
    
    private func addFriend() {
        isLoading = true
        errorMessage = nil
        
        leetCodeVM.fetchData(for: username) { success in
            isLoading = false
            if success {
                savedUsersVM.addUsername(username)
                username = ""
                isPresented = false
            } else {
                errorMessage = "Could not find that LeetCode username. Please try again."
            }
        }
    }
} 

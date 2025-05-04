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
                            Text("Primary")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.15))
                                .cornerRadius(6)
                        } else {
                            Button(action: {
                                savedUsersVM.changePrimaryUsername(username)
                            }) {
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
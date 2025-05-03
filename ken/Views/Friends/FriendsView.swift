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
    
    var body: some View {
        VStack {
            if savedUsersVM.savedUsernames.isEmpty {
                VStack(spacing: 20) {
                    Text("You haven't added any friends yet")
                        .font(.headline)
                    
                    Button(action: { showingAddSheet = true }) {
                        Label("Add Friend", systemImage: "person.badge.plus")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(savedUsersVM.savedUsernames, id: \.self) { username in
                        HStack {
                            FriendRowView(username: username, leetCodeVM: leetCodeVM)
                            
                            Spacer()
                            
                            if username == savedUsersVM.primaryUsername {
                                Text("Primary")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .padding(4)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(4)
                            } else {
                                Button(action: {
                                    savedUsersVM.changePrimaryUsername(username)
                                }) {
                                    Text("Make Primary")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .contextMenu {
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
                        }
                    }
                }
                
                Button(action: { showingAddSheet = true }) {
                    Label("Add Friend", systemImage: "person.badge.plus")
                        .padding()
                }
            }
        }
        .navigationTitle("Friends")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "person.badge.plus")
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
        .onAppear {
            // Load data for all saved users
            for username in savedUsersVM.savedUsernames {
                leetCodeVM.fetchData(for: username)
            }
        }
    }
}

struct FriendRowView: View {
    let username: String
    @ObservedObject var leetCodeVM: LeetCodeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(username)
                .font(.headline)
            
            if let stats = leetCodeVM.userStats[username] {
                HStack(spacing: 12) {
                    Label("\(stats.totalSolved)", systemImage: "checkmark.circle")
                        .font(.caption)
                    
                   
                }
                .foregroundColor(.gray)
            } else {
                Text("Loading...")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddFriendView: View {
    @ObservedObject var leetCodeVM: LeetCodeViewModel
    @ObservedObject var savedUsersVM: SavedUsersViewModel
    @Binding var isPresented: Bool
    @Binding var username: String
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("LeetCode Username", text: $username)
                    .padding()
                    .background(Color(.systemGray6))
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

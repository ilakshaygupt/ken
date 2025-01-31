//
//  SavedUsersView.swift
//  ken
//
//  Created by Lakshay Gupta on 31/01/25.
//


import SwiftUI
struct SavedUsersView: View {
    @ObservedObject var savedUsersVM: SavedUsersViewModel
    @ObservedObject var leetCodeVM: LeetCodeViewModel
    
    var body: some View {
        List {
            ForEach(savedUsersVM.savedUsernames, id: \.self) { username in
                NavigationLink(destination: UserDetailView(username: username, leetCodeVM: leetCodeVM)) {
                    UserRowView(username: username, leetCodeVM: leetCodeVM)
                        .swipeActions {
                            Button(role: .destructive) {
                                savedUsersVM.removeUsername(username)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .onAppear {
            savedUsersVM.savedUsernames.forEach { username in
                leetCodeVM.fetchData(for: username)
            }
        }
    }
}

struct UserRowView: View {
    let username: String
    @ObservedObject var leetCodeVM: LeetCodeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(username)
                .font(.headline)
            
            if let stats = leetCodeVM.userStats[username] {
                HStack {
                    Text("Solved: \(stats.totalSolved)")
                        .foregroundColor(.secondary)
                   
                }
                .font(.subheadline)
            }
        }
        .padding(.vertical, 4)
    }
}

struct UserDetailView: View {
    let username: String
    @ObservedObject var leetCodeVM: LeetCodeViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                VStack(alignment: .leading, spacing: 8) {
                    Text(username)
                        .font(.title)
                        .bold()
                    
                    
                    
                    if let stats = leetCodeVM.userStats[username] {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Statistics")
                                .font(.title2)
                                .bold()
                            
                            StatsView(stats: stats)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                    
                    if let calendar = leetCodeVM.userCalendars[username] {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Activity")
                                .font(.title2)
                                .bold()
                            
                            CalendarView(calendar: calendar)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
        }
    }
}

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
    
    var body: some View {
        VStack {
            if let primaryUsername = savedUsersVM.primaryUsername {
                if savedUsersVM.savedUsernames.count > 1 {
                    VStack {
                        Text("Compare with:")
                            .font(.headline)
                        
                        Picker("Select user to compare with", selection: $selectedUsername) {
                            ForEach(savedUsersVM.savedUsernames.filter { $0 != primaryUsername }, id: \.self) { username in
                                Text(username).tag(username as String?)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding()
                    }
                    
                    if let selectedUsername = selectedUsername,
                       let primaryStats = leetCodeVM.userStats[primaryUsername],
                       let compareStats = leetCodeVM.userStats[selectedUsername] {
                        
                        ComparisonView(primaryUsername: primaryUsername, 
                                      compareUsername: selectedUsername,
                                      primaryStats: primaryStats,
                                      compareStats: compareStats)
                    } else {
                        Text("Select a user to compare with \(primaryUsername)")
                            .foregroundColor(.gray)
                            .padding()
                    }
                } else {
                    Text("Add more users to compare with \(primaryUsername)")
                        .foregroundColor(.gray)
                        .padding()
                }
            } else {
                Text("Primary username not set")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
        .onAppear {
            // Initialize selected username if possible
            if selectedUsername == nil,
               let primaryUsername = savedUsersVM.primaryUsername,
               let firstOtherUser = savedUsersVM.savedUsernames.first(where: { $0 != primaryUsername }) {
                selectedUsername = firstOtherUser
            }
            
            // Load data for all saved users
            for username in savedUsersVM.savedUsernames {
                leetCodeVM.fetchData(for: username)
            }
        }
    }
}

struct ComparisonView: View {
    let primaryUsername: String
    let compareUsername: String
    let primaryStats: UserStats
    let compareStats: UserStats
    
    var body: some View {
        VStack(spacing: 15) {
            Text("\(primaryUsername) vs \(compareUsername)")
                .font(.headline)
                .padding(.bottom, 5)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Total Solved:")
                    Text("Easy Solved:")
                    Text("Medium Solved:")
                    Text("Hard Solved:")
                    Text("Ranking:")
                }
                
                VStack(alignment: .trailing) {
                    Text("\(primaryStats.totalSolved)")
                    Text("\(primaryStats.easySolved)")
                    Text("\(primaryStats.mediumSolved)")
                    Text("\(primaryStats.hardSolved)")
                    
                }
                .foregroundColor(.blue)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(compareStats.totalSolved)")
                    Text("\(compareStats.easySolved)")
                    Text("\(compareStats.mediumSolved)")
                    Text("\(compareStats.hardSolved)")
                    
                }
                .foregroundColor(.green)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            
            Text("Comparison Chart")
                .frame(maxWidth: .infinity, minHeight: 200)
                .background(Color(.systemGray5))
                .cornerRadius(8)
        }
        .padding()
    }
} 

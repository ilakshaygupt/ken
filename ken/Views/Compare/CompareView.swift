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
                                
                            // NavigationLink(destination: SavedUsersView(savedUsersVM: savedUsersVM, leetCodeVM: leetCodeVM)) {
                            //     Text("Add Users")
                            //         .fontWeight(.semibold)
                            //         .foregroundColor(.white)
                            //         .padding(.vertical, 12)
                            //         .padding(.horizontal, 30)
                            //         .background(Color.blue)
                            //         .cornerRadius(10)
                            // }
                            // .padding(.top, 20)
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

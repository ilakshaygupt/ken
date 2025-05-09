//
//  CompareView.swift
//  ken
//
//  Created by Lakshay Gupta on 03/05/25.
//
import SwiftUI
import Foundation
import Combine


struct CompareView: View {
    @ObservedObject var leetCodeVM: LeetCodeViewModel
    @ObservedObject var savedUsersVM: SavedUsersViewModel
    @State private var selectedUsername: String?
    @Environment(\.colorScheme) private var colorScheme
    @State private var scrollOffset: CGFloat = 0
    
    private let collapsedHeight: CGFloat = 100
    private let expandedHeight: CGFloat = 230
    
    private var computedHeaderHeight: CGFloat {
        print("scroll offset \(scrollOffset)")
        if scrollOffset > 40 {
            let percentage = min(1, (scrollOffset - 50) / 100)
            return expandedHeight - (expandedHeight - collapsedHeight) * percentage
        } else {
            return expandedHeight
        }
        
    }
    
    private var backgroundColor: Color {
        AppTheme.shared.backgroundColor(in: colorScheme)
    }
    
    public init(leetCodeVM: LeetCodeViewModel, savedUsersVM: SavedUsersViewModel) {
        self.leetCodeVM = leetCodeVM
        self.savedUsersVM = savedUsersVM
    }
    
    @ViewBuilder
    private func userAvatarView(for profile: UserProfile) -> some View {
        if let avatarUrl = profile.userAvatar, !avatarUrl.isEmpty {
            AsyncImage(url: URL(string: avatarUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundColor(.gray)
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
        } else {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.gray)
        }
    }

    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                if let primaryUsername = savedUsersVM.primaryUsername {
                    
                    VStack(spacing: 0) {
                        // Enhanced header container
                        VStack(spacing: 10) {
                            if let userProfile = leetCodeVM.userProfiles[primaryUsername] {
                                if computedHeaderHeight > collapsedHeight + (expandedHeight - collapsedHeight) * 0.5 {
                                    // Expanded: VStack layout with improved visuals
                                    VStack(alignment: .center, spacing: 12) {
                                        ZStack {
                                            Circle()
                                                
                                                .frame(width: 86, height: 86)
                                            
                                            userAvatarView(for: userProfile)
                                                .frame(width: 80, height: 80)
                                                .clipShape(Circle())
                                                
                                        }
                                        
                                        VStack(spacing: 4) {
                                            Text(userProfile.realName ?? primaryUsername)
                                                .font(.title3)
                                                .fontWeight(.bold)
                                        }
                                    }
                                    .padding(.vertical, 12)
                                    .transition(.asymmetric(
                                        insertion: .opacity.combined(with: .scale(scale: 0.95)),
                                        removal: .opacity.combined(with: .scale(scale: 0.95))
                                    ))
                                } else {
                                   
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .frame(width: 42, height: 42)
                                            userAvatarView(for: userProfile)
                                                .frame(width: 38, height: 38)
                                                .clipShape(Circle())
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(userProfile.realName ?? primaryUsername)
                                                .font(.headline)
                                                .lineLimit(1)
                                            
                                            if let jobTitle = userProfile.jobTitle, !jobTitle.isEmpty {
                                                Text(jobTitle)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                    .lineLimit(1)
                                            }
                                        }
                                    }
                                    .padding(.vertical, 8)
                                    .transition(.asymmetric(
                                        insertion: .opacity.combined(with: .move(edge: .top)),
                                        removal: .opacity.combined(with: .move(edge: .top))
                                    ))
                                }
                            }
                            
                            // Enhanced Compare section
                            if savedUsersVM.savedUsernames.count > 1 {
                                VStack(spacing: 8) {
                                    if computedHeaderHeight > collapsedHeight + (expandedHeight - collapsedHeight) * 0.5 {
                                        // Expanded compare section
                                        VStack(spacing: 8) {
                                            Text("Compare with:")
                                                .font(.headline)
                                            
                                            Menu {
                                                ForEach(savedUsersVM.savedUsernames.filter { $0 != primaryUsername }, id: \.self) { username in
                                                    Button(action: {
                                                        withAnimation(.spring()) {
                                                            selectedUsername = username
                                                        }
                                                    }) {
                                                        HStack {
                                                            if let userAvatar = leetCodeVM.userProfiles[username]?.userAvatar {
                                                                AsyncImage(url: URL(string: userAvatar)) { image in
                                                                    image
                                                                        .resizable()
                                                                        .scaledToFill()
                                                                } placeholder: {
                                                                    Image(systemName: "person.circle.fill")
                                                                }
                                                                .frame(width: 20, height: 20)
                                                                .clipShape(Circle())
                                                            }
                                                            
                                                            Text(username)
                                                                .font(.subheadline)
                                                            
                                                            Spacer()
                                                            
                                                            if selectedUsername == username {
                                                                Image(systemName: "checkmark")
                                                                    
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                                Divider()
                                                
                                                Button(role: .destructive, action: {
                                                    selectedUsername = nil
                                                }) {
                                                    Label("Clear Comparison", systemImage: "xmark.circle")
                                                }
                                            } label: {
                                                HStack {
                                                    if let selectedUsername = selectedUsername,
                                                       let userAvatar = leetCodeVM.userProfiles[selectedUsername]?.userAvatar {
                                                        AsyncImage(url: URL(string: userAvatar)) { image in
                                                            image
                                                                .resizable()
                                                                .scaledToFill()
                                                        } placeholder: {
                                                            Image(systemName: "person.circle.fill")
                                                        }
                                                        .frame(width: 24, height: 24)
                                                        .clipShape(Circle())
                                                    } else {
                                                        Image(systemName: "person.2.fill")
                                                            
                                                    }
                                                    
                                                    Text(selectedUsername ?? "Select user")
                                                        .lineLimit(1)
                                                    
                                                    Spacer()
                                                    
                                                    Image(systemName: "chevron.down")
                                                        .font(.caption)
                                                }
                                                .foregroundColor(.primary)
                                                .padding(.vertical, 10)
                                                .padding(.horizontal, 16)

                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    } else {
                                        // Collapsed compare section
                                        HStack(spacing: 10) {
                                            Text("Compare:")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            
                                            Menu {
                                                ForEach(savedUsersVM.savedUsernames.filter { $0 != primaryUsername }, id: \.self) { username in
                                                    Button(action: {
                                                        withAnimation(.spring()) {
                                                            selectedUsername = username
                                                        }
                                                    }) {
                                                        HStack {
                                                            Text(username)
                                                            Spacer()
                                                            if selectedUsername == username {
                                                                Image(systemName: "checkmark")
                                                                    
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                                Divider()
                                                
                                                Button(role: .destructive, action: {
                                                    selectedUsername = nil
                                                }) {
                                                    Label("Clear", systemImage: "xmark.circle")
                                                }
                                            } label: {
                                                HStack(spacing: 4) {
                                                    Text(selectedUsername ?? "Select")
                                                        .lineLimit(1)
                                                    
                                                    Image(systemName: "chevron.down")
                                                        .font(.caption)
                                                }
                                                .padding(.vertical, 6)
                                                .padding(.horizontal, 12)
                                            
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }
                                .padding(.top, 4)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, computedHeaderHeight > collapsedHeight + (expandedHeight - collapsedHeight) * 0.5 ? 16 : 12)
                        .frame(height: computedHeaderHeight)
                        .frame(maxWidth: .infinity)
                      
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color.gray.opacity(0.15)),
                            alignment: .bottom
                        )
                        .clipShape(RoundedRectangle(cornerRadius: computedHeaderHeight > collapsedHeight + (expandedHeight - collapsedHeight) * 0.8 ? 12 : 0))
                        .shadow(
                            color: Color.black.opacity(0.08),
                            radius: computedHeaderHeight > collapsedHeight + (expandedHeight - collapsedHeight) * 0.5 ? 5 : 3,
                            x: 0,
                            y: 2
                        )
                        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: computedHeaderHeight)
                    }

                    
                    if savedUsersVM.savedUsernames.count > 1 {
                        if let selectedUsername = selectedUsername,
                           let primaryStats = leetCodeVM.userStats[primaryUsername],
                           let compareStats = leetCodeVM.userStats[selectedUsername] {
                            
                            ScrollView {
                                Color.clear.frame(height: 1)
                                
                                VStack(spacing: 15) {
                                    ComparisonView(
                                        primaryUsername: primaryUsername,
                                        compareUsername: selectedUsername,
                                        primaryStats: primaryStats,
                                        compareStats: compareStats,
                                        leetCodeVM: leetCodeVM
                                    )
                                }
                                .padding(.vertical)
                                
                            }
                            .onScrollGeometryChange(for: Double.self) { geo in
                                            geo.contentOffset.y
                                        } action: { oldValue, newValue in
                                            print("new scroll offset \(newValue)  old value \(oldValue) ")
                                            scrollOffset = newValue
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
        .navigationTitle(computedHeaderHeight > collapsedHeight + (expandedHeight - collapsedHeight) * 0.5 ?"Compare" : "Compare")
        .navigationBarHidden(computedHeaderHeight > collapsedHeight + (expandedHeight - collapsedHeight) * 0.5 ? true : true)
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
        
    }
}


extension View {
    func trackScrollOffset(onChange: @escaping (CGFloat) -> Void) -> some View {
        background(
            GeometryReader { geo in
                Color.clear.preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: geo.frame(in: .named("scrollView")).minY
                )
            }
        )
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            onChange(-value)
        }
    }
}

// Preference key for tracking scroll offset
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    ComparePreviewHelper.makeCompareView()
}

struct ComparePreviewHelper {
    static func makeCompareView() -> some View {
        let leetCodeVM = LeetCodeViewModel()
        let savedUsersVM = SavedUsersViewModel()

        savedUsersVM.savedUsernames = ["alice", "bob"]
        savedUsersVM.primaryUsername = "alice"

        leetCodeVM.userProfiles["alice"] = UserProfile(
            username: "alice",
            githubUrl: nil,
            twitterUrl: nil,
            linkedinUrl: nil,
            userAvatar: nil,
            realName: "Alice",
            aboutMe: "iOS Developer passionate about clean code.",
            school: "Tech University",
            websites: [],
            countryName: "USA",
            company: "Tech Inc.",
            jobTitle: "iOS Developer",
            skillTags: ["Swift", "UIKit"],
            ranking: 1234,
            contestBadge: nil
        )

        leetCodeVM.userProfiles["bob"] = UserProfile(
            username: "bob",
            githubUrl: nil,
            twitterUrl: nil,
            linkedinUrl: nil,
            userAvatar: nil,
            realName: "Bob",
            aboutMe: "Backend engineer who loves APIs.",
            school: "Dev University",
            websites: [],
            countryName: "Canada",
            company: "DevCorp",
            jobTitle: "Backend Engineer",
            skillTags: ["Python", "Django"],
            ranking: 2345,
            contestBadge: nil
        )

        leetCodeVM.userStats["alice"] = UserStats(
            totalSolved: 150,
            easySolved: 50,
            mediumSolved: 70,
            hardSolved: 30,
            easyTotal: 100,
            mediumTotal: 150,
            hardTotal: 50,
            totalProblems: 300,
            ranking: 1234
        )

        leetCodeVM.userStats["bob"] = UserStats(
            totalSolved: 100,
            easySolved: 40,
            mediumSolved: 50,
            hardSolved: 10,
            easyTotal: 100,
            mediumTotal: 150,
            hardTotal: 50,
            totalProblems: 300,
            ranking: 2345
        )

        return CompareView(leetCodeVM: leetCodeVM, savedUsersVM: savedUsersVM)
            .preferredColorScheme(.light)
    }
}

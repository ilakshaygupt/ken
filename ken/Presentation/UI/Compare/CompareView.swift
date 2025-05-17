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
    
    private let maxHeight: CGFloat = 230
    private let minHeight: CGFloat = 100
    
    enum HeaderState {
        case expanded
        case collapsed
    }
    
    @State private var headerState: HeaderState = .expanded
    
    private var headerHeight: CGFloat {
        let offset = scrollOffset
        let extraSpace = maxHeight - minHeight
        
        let clampedOffset = max(0, min(offset, extraSpace))
        let height = maxHeight - clampedOffset
        
        return height
    }
    
    private var headerOffset: CGFloat {
        let offset = scrollOffset
        let extraSpace = maxHeight - minHeight
        
        let calculatedOffset = offset < extraSpace ? 0 : offset - extraSpace
        return calculatedOffset
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
        ZStack(alignment: .top) {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                if let primaryUsername = savedUsersVM.primaryUsername {
                    if let userProfile = leetCodeVM.userProfiles[primaryUsername] {
                        if headerState == .expanded {
                            HStack(alignment: .center, spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.1))
                                        .frame(width: 86, height: 86)
                                    
                                    userAvatarView(for: userProfile)
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                                        )
                                }
                                
                                VStack(spacing: 4) {
                                    Text(userProfile.realName ?? primaryUsername)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                    
                                    if let jobTitle = userProfile.jobTitle, !jobTitle.isEmpty {
                                        Text(jobTitle)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
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
                                        .fill(Color.blue.opacity(0.1))
                                        .frame(width: 42, height: 42)
                                    userAvatarView(for: userProfile)
                                        .frame(width: 38, height: 38)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                        )
                                }
                                
                                Text(userProfile.realName ?? primaryUsername)
                                    .font(.headline)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                if savedUsersVM.savedUsernames.count > 1 {
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
                                                    .foregroundColor(.green)
                                            }
                                            
                                            Text(selectedUsername ?? "Compare")
                                                .lineLimit(1)
                                            
                                            Image(systemName: "chevron.down")
                                                .font(.caption)
                                        }
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 12)
                                        .background(Color.secondary.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.clear)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .top)),
                                removal: .opacity.combined(with: .move(edge: .top))
                            ))
                        }
                    }
                    if savedUsersVM.savedUsernames.count > 1 {
                        VStack(spacing: 8) {
                            if headerState == .expanded {
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
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                                )
                                            } else {
                                                Image(systemName: "person.2.fill")
                                                    .foregroundColor(.green)
                                            }
                                            
                                            Text(selectedUsername ?? "Select user")
                                                .lineLimit(1)
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.down")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 16)
                                        .background(Color.secondary.opacity(0.1))
                                        .cornerRadius(10)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            } 
                        }
                        .padding(.top, 4)
                        .background(headerState == .expanded ? backgroundColor : Color.clear)
                    }
                    ScrollView {
                        GeometryReader { geometry in
                            Color.clear
                                .preference(
                                    key: ScrollOffsetPreferenceKey.self,
                                    value: geometry.frame(in: .named("scrollView")).minY
                                )
                                .onChange(of: geometry.frame(in: .named("scrollView")).minY) { newValue in
                                    scrollOffset = newValue
                                    updateHeaderState(offset: newValue)
                                }
                        }
                        .frame(height: 0)
                        
                        VStack(spacing: 15) {
                            if let selectedUsername = selectedUsername,
                               let primaryStats = leetCodeVM.userStats[primaryUsername],
                               let compareStats = leetCodeVM.userStats[selectedUsername] {
                                ComparisonView(
                                    primaryUsername: primaryUsername,
                                    compareUsername: selectedUsername,
                                    primaryStats: primaryStats,
                                    compareStats: compareStats,
                                    leetCodeVM: leetCodeVM
                                )
                            }

                        }
                    }
                    .coordinateSpace(name: "scrollView")
                }
                else {
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
            .navigationTitle(headerState == .expanded ? "Compare" : "Compare")
            .navigationBarHidden(true)
            .onAppear {
                if selectedUsername == nil,
                   let primaryUsername = savedUsersVM.primaryUsername,
                   let firstOtherUser = savedUsersVM.savedUsernames.first(where: { $0 != primaryUsername }) {
                    selectedUsername = firstOtherUser
                }
                
                for username in savedUsersVM.savedUsernames {
                    leetCodeVM.fetchData(for: username)
                }
                
                for username in savedUsersVM.savedUsernames {
                    leetCodeVM.fetchUserProfile(for: username)
                }
            }
            
        }
    }
    
    private func getOffset(offset: CGFloat) -> CGFloat {
        let absOffset = abs(offset)
        let extraSpace = maxHeight - minHeight
                
        if absOffset < extraSpace {
            return -absOffset
        } else {
            return -extraSpace
        }
    }
    
    private func updateHeaderState(offset: CGFloat) {
        let absOffset = abs(offset)
        let extraSpace = (maxHeight - minHeight) * 0.5 
        
        if absOffset < extraSpace {
            if headerState != .expanded {
                withAnimation(.smooth) {
                    headerState = .expanded
                }
            }
        } else {
            if headerState != .collapsed {
                withAnimation(.smooth) {
                    headerState = .collapsed
                }
            }
        }
    }
}

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

        savedUsersVM.savedUsernames = ["demolisherguts", "bob"]
        savedUsersVM.primaryUsername = "demolisherguts"

        leetCodeVM.userProfiles["demolisherguts"] = UserProfile(
            username: "demolisherguts",
            githubUrl: nil,
            twitterUrl: nil,
            linkedinUrl: nil,
            userAvatar: nil,
            realName: "demolisherguts",
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

        leetCodeVM.userStats["demolisherguts"] = UserStats(
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

//
//  CompareView.swift
//  ken
//
//  Created by Lakshay Gupta on 03/05/25.
//
import SwiftUI
import Foundation
import Combine

// MARK: - CompareView
struct CompareView: View {
    @EnvironmentObject private var leetCodeVM: LeetCodeViewModel
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
    
    public init(savedUsersVM: SavedUsersViewModel) {
        self.savedUsersVM = savedUsersVM
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                if let primaryUsername = savedUsersVM.primaryUsername {
                    // Header Section
                    HeaderView(
                        primaryUsername: primaryUsername,
                        selectedUsername: $selectedUsername,
                        headerState: headerState,
                        savedUsersVM: savedUsersVM,
                        leetCodeVM: leetCodeVM,
                        backgroundColor: backgroundColor
                    )
                    
                    // Main Content
                    ScrollView {
                        // Scroll Position Detector
                        ScrollPositionDetectorView(
                            scrollOffset: $scrollOffset,
                            updateHeaderState: updateHeaderState
                        )
                        
                        // Comparison Content
                        ComparisonContentView(
                            primaryUsername: primaryUsername,
                            selectedUsername: selectedUsername,
                            leetCodeVM: leetCodeVM
                        )
                    }
                    .coordinateSpace(name: "scrollView")
                } else {
                    NoPrimaryUserView()
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                setupInitialUser()
            }
            .onChange(of: selectedUsername) { newUsername in
                fetchDataForSelectedUser(newUsername)
            }
        }
    }
    
    private func setupInitialUser() {
        if selectedUsername == nil,
           let primaryUsername = savedUsersVM.primaryUsername,
           let firstOtherUser = savedUsersVM.savedUsernames.first(where: { $0 != primaryUsername }) {
            selectedUsername = firstOtherUser
        }
        
        if let primaryUsername = savedUsersVM.primaryUsername {
            Task {
                async let dataFetch = leetCodeVM.fetchData(for: primaryUsername)
                async let profileFetch = leetCodeVM.fetchUserProfile(for: primaryUsername)
                
                let _ = await (dataFetch, profileFetch)
            }
        }
    }

    private func fetchDataForSelectedUser(_ username: String?) {
        guard let username = username else { return }
        
        Task {
            async let dataFetch = leetCodeVM.fetchData(for: username)
            async let profileFetch = leetCodeVM.fetchUserProfile(for: username)
            
            let _ = await (dataFetch, profileFetch)
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

// MARK: - ScrollPositionDetectorView
struct ScrollPositionDetectorView: View {
    @Binding var scrollOffset: CGFloat
    let updateHeaderState: (CGFloat) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: geometry.frame(in: .named("scrollView")).minY
                )
                .onChange(of: geometry.frame(in: .named("scrollView")).minY) { newValue in
                    scrollOffset = newValue
                    updateHeaderState(newValue)
                }
        }
        .frame(height: 0)
    }
}

// MARK: - HeaderView
struct HeaderView: View {
    let primaryUsername: String
    @Binding var selectedUsername: String?
    let headerState: CompareView.HeaderState
    let savedUsersVM: SavedUsersViewModel
    let leetCodeVM: LeetCodeViewModel
    let backgroundColor: Color
    
    var body: some View {
        VStack(spacing: 0) {
            if let userProfile = leetCodeVM.userProfiles[primaryUsername] {
                if headerState == .expanded {
                    ExpandedHeaderView(userProfile: userProfile, primaryUsername: primaryUsername)
                } else {
                    CollapsedHeaderView(
                        userProfile: userProfile,
                        primaryUsername: primaryUsername,
                        savedUsersVM: savedUsersVM,
                        selectedUsername: $selectedUsername,
                        leetCodeVM: leetCodeVM
                    )
                }
            }
            
            if savedUsersVM.savedUsernames.count > 1 {
                CompareSelectionView(
                    primaryUsername: primaryUsername,
                    selectedUsername: $selectedUsername,
                    headerState: headerState,
                    savedUsersVM: savedUsersVM,
                    leetCodeVM: leetCodeVM,
                    backgroundColor: backgroundColor
                )
            }
        }
    }
}

// MARK: - ExpandedHeaderView
struct ExpandedHeaderView: View {
    let userProfile: UserProfile
    let primaryUsername: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 86, height: 86)
                
                UserAvatarView(userProfile: userProfile,animate: true)
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
    }
}

// MARK: - CollapsedHeaderView
struct CollapsedHeaderView: View {
    let userProfile: UserProfile
    let primaryUsername: String
    let savedUsersVM: SavedUsersViewModel
    @Binding var selectedUsername: String?
    let leetCodeVM: LeetCodeViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 42, height: 42)
                UserAvatarView(userProfile: userProfile,animate: true)
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
                UserSelectionMenu(
                    primaryUsername: primaryUsername,
                    selectedUsername: $selectedUsername,
                    savedUsersVM: savedUsersVM,
                    leetCodeVM: leetCodeVM,
                    isCollapsed: true
                )
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

// MARK: - CompareSelectionView
struct CompareSelectionView: View {
    let primaryUsername: String
    @Binding var selectedUsername: String?
    let headerState: CompareView.HeaderState
    let savedUsersVM: SavedUsersViewModel
    let leetCodeVM: LeetCodeViewModel
    let backgroundColor: Color
    
    var body: some View {
        VStack(spacing: 8) {
            if headerState == .expanded {
                VStack(spacing: 8) {
                    Text("Compare with:")
                        .font(.headline)
                    
                    UserSelectionMenu(
                        primaryUsername: primaryUsername,
                        selectedUsername: $selectedUsername,
                        savedUsersVM: savedUsersVM,
                        leetCodeVM: leetCodeVM,
                        isCollapsed: false
                    )
                }
            }
        }
        .padding(.top, 4)
        .background(headerState == .expanded ? backgroundColor : Color.clear)
    }
}

// MARK: - UserSelectionMenu
struct UserSelectionMenu: View {
    let primaryUsername: String
    @Binding var selectedUsername: String?
    let savedUsersVM: SavedUsersViewModel
    let leetCodeVM: LeetCodeViewModel
    let isCollapsed: Bool
    
    var body: some View {
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
                            .frame(width: isCollapsed ? 20 : 20, height: isCollapsed ? 20 : 20)
                            .clipShape(Circle())
                        }
                        
                        Text(username)
                            .font(isCollapsed ? .body : .subheadline)
                        
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
                Label(isCollapsed ? "Clear" : "Clear Comparison", systemImage: "xmark.circle")
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
                    .if(!isCollapsed) { view in
                        view.overlay(
                            Circle()
                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                        )
                    }
                } else {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(.green)
                }
                
                Text(selectedUsername ?? (isCollapsed ? "Compare" : "Select user"))
                    .lineLimit(1)
                
                if !isCollapsed {
                    Spacer()
                }
                
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .if(!isCollapsed) { view in
                        view.foregroundColor(.secondary)
                    }
            }
            .padding(.vertical, isCollapsed ? 6 : 10)
            .padding(.horizontal, isCollapsed ? 12 : 16)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(isCollapsed ? 8 : 10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - ComparisonContentView
struct ComparisonContentView: View {
    let primaryUsername: String
    let selectedUsername: String?
    let leetCodeVM: LeetCodeViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            if let selectedUsername = selectedUsername,
               let primaryStats = leetCodeVM.userStats[primaryUsername],
               let compareStats = leetCodeVM.userStats[selectedUsername] {
                ComparisonView(
                    primaryUsername: primaryUsername,
                    compareUsername: selectedUsername,
                    primaryStats: primaryStats,
                    compareStats: compareStats
                )
            }
        }
    }
}

// MARK: - ScrollOffsetPreferenceKey
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview Helper
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

        return CompareView(savedUsersVM: savedUsersVM)
            .environmentObject(leetCodeVM)
            .preferredColorScheme(.light)
    }
}

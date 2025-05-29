//
//  SplashScreenView.swift
//  ken
//
//  Created by Lakshay Gupta on 04/05/25.
//

import SwiftUI

struct SplashScreenView: View {
    @Binding var hasCompletedOnboarding: Bool
    @ObservedObject var savedUsersVM: SavedUsersViewModel
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var leetCodeVM : LeetCodeViewModel

    @State private var showLogo = false
    @State private var showTitle = false
    @State private var showLoadingText = false
    @State private var isActive = false
    @State private var isLoading = true

    private var backgroundColor: Color {
        AppTheme.shared.backgroundColor(in: colorScheme)
    }
    
    var body: some View {
        if isActive {
            if hasCompletedOnboarding {
                ContentView()
                    .environmentObject(savedUsersVM)
                    .environmentObject(leetCodeVM)
            } else {
                OnboardingView(savedUsersVM: savedUsersVM)
            }
        } else {
            ZStack {
                backgroundColor.ignoresSafeArea()

                GeometryReader { geometry in
                    ZStack {
                        VStack(spacing: 16) {
                            Image("icon")
                                .resizable()
                                .frame(width: 200, height: 200)
                                .opacity(showLogo ? 1 : 0)
                                .offset(y: showLogo ? 0 : -100)
                                .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.3), value: showLogo)

                            Text("KenCode")
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .opacity(showTitle ? 1 : 0)
                                .offset(y: showTitle ? 0 : 60)
                                .animation(.easeOut(duration: 0.6).delay(0.8), value: showTitle)
                            
                            if showLoadingText {
                                VStack(spacing: 15) {
                                    ProgressView()
                                        .scaleEffect(1.2)
                                        .tint(.blue)
                                    
                                    Text("Loading your data...")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .opacity(0.8)
                                }
                                .transition(.opacity)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .onAppear {
                showLogo = true
                showTitle = true
                
                Task {
                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                    withAnimation {
                        showLoadingText = true
                    }
                    
                    for username in savedUsersVM.savedUsernames {
                        let success = await leetCodeVM.fetchData(for: username)
                        print("Fetched data for \(username): \(success)")
                    }
                            
                    try? await Task.sleep(nanoseconds: 500_000_000) 
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}


#Preview {
    SplashScreenView(
        hasCompletedOnboarding: .constant(false),
        savedUsersVM: SavedUsersViewModel()
    )
}

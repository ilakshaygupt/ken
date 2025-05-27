//
//  ContentView.swift
//  ken
//
//  Created by Lakshay Gupta on 25/04/25.
//
//
//  ContentView.swift
//  ken
//
//  Created by Lakshay Gupta on 25/04/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var leetCodeVM : LeetCodeViewModel
    @EnvironmentObject private var savedUsersVM: SavedUsersViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var isLoading = true
    
    var body: some View {
        if isLoading {
            
            
            LoadingScreenView()
                .onAppear {
                    Task {
                        try? await Task.sleep(nanoseconds: 1_000_000_000)

                        for username in savedUsersVM.savedUsernames {
                            let success = await leetCodeVM.fetchData(for: username)
                            print("Fetched data for \(username): \(success)")
                        }

                        isLoading = false
                    }

                }
        } else {
            MainTabView(savedUsersVM: savedUsersVM, colorScheme: colorScheme)
        }
    }
}

struct LoadingScreenView: View {
    @State private var animationAmount = 0.0
    @State private var pulseAmount = 1.0
    @State private var isAnimating = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            
            VStack(spacing: 30) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(pulseAmount)
                    
                    Image("icon")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .rotationEffect(.degrees(animationAmount))
                }
                .animation(
                    .easeInOut(duration: 2)
                    .repeatForever(autoreverses: true),
                    value: pulseAmount
                )
                
                VStack(spacing: 15) {
                    Text("LeetCode Tracker")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Loading your data...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 15) {
                    ZStack {
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 4
                            )
                            .frame(width: 50, height: 50)
                        
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(.blue)
                    }
                    
                    Text("Fetching user profiles and stats")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .opacity(0.8)
                }
                
      
            }
        }
        .onAppear {
            animationAmount = 360
            pulseAmount = 1.3
            isAnimating = true
        }
    }
}

struct MainTabView: View {
    let savedUsersVM: SavedUsersViewModel
    let colorScheme: ColorScheme
    
    var body: some View {
        TabView {
            NavigationStack {
                HomeView(savedUsersVM: savedUsersVM)
                    .navigationTitle("Home")
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            
            
            NavigationStack {
                CompareView(savedUsersVM: savedUsersVM)
                    .navigationTitle("Compare")
            }
            .tabItem {
                Label("Compare", systemImage: "chart.bar.xaxis")
            }
            
            NavigationStack {
                FriendsView(savedUsersVM: savedUsersVM)
                    .navigationTitle("Friends")
            }
            .tabItem {
                Label("Friends", systemImage: "person.2")
            }
            
            NavigationStack {
                ScrollView {
                    SearchView()
                }
                .navigationTitle("Search")
                .background(AppTheme.shared.backgroundColor(in: colorScheme))
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
        }
    }
}

#Preview {
    ContentView()
}

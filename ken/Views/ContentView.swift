//
//  ContentView.swift
//  ken
//
//  Created by Lakshay Gupta on 25/04/25.
//


import SwiftUI

struct ContentView: View {
    @StateObject private var leetCodeVM = LeetCodeViewModel()
    @EnvironmentObject private var savedUsersVM: SavedUsersViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        TabView {
            
            NavigationView {
                HomeView(leetCodeVM: leetCodeVM, savedUsersVM: savedUsersVM)
                    .navigationTitle("Home")
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Home", systemImage: "house")
            }
            
            
            NavigationView {
                CompareView(leetCodeVM: leetCodeVM, savedUsersVM: savedUsersVM)
                    .navigationTitle("Compare")
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Compare", systemImage: "chart.bar.xaxis")
            }
            
            
            NavigationView {
                FriendsView(leetCodeVM: leetCodeVM, savedUsersVM: savedUsersVM)
                    .navigationTitle("Friends")
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Friends", systemImage: "person.2")
            }
            
            
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        SearchBar(username: $leetCodeVM.currentUsername) {
                            leetCodeVM.fetchData(for: leetCodeVM.currentUsername)
                            savedUsersVM.addUsername(leetCodeVM.currentUsername)
                        }
                        .disabled(leetCodeVM.isLoading)
                        
                        if leetCodeVM.isLoading {
                            ProgressView()
                        } else {
                            if let stats = leetCodeVM.userStats[leetCodeVM.currentUsername] {
                                StatsView(stats: stats)
                                    .background(AppTheme.shared.cardBackgroundColor(in: colorScheme))
                                    .cornerRadius(8)
                            }
                            
                            if let calendar = leetCodeVM.userCalendars[leetCodeVM.currentUsername] {
                                CalendarView(calendar: calendar)
                                    .background(AppTheme.shared.cardBackgroundColor(in: colorScheme))
                                    .cornerRadius(8)
                            }
                        }
                        
                        if let error = leetCodeVM.error {
                            ErrorView(message: error.localizedDescription)
                        }
                    }
                    .padding()
                }
                .navigationTitle("Search")
                .background(AppTheme.shared.backgroundColor(in: colorScheme))
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            
        }
        .tabViewStyle(.tabBarOnly)
        .onAppear {
            if let primaryUsername = savedUsersVM.primaryUsername {
                leetCodeVM.fetchData(for: primaryUsername)
            }
        }
    }
} 

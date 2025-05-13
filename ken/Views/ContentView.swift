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
//                    .navigationTitle("Compare")
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
                    SearchView()
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


#Preview {
    ContentView()
}

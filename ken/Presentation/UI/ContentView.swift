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

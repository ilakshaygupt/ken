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
            NavigationView {
                HomeView(savedUsersVM: savedUsersVM)
                    .navigationTitle("Home")
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .navigationViewStyle(StackNavigationViewStyle())

            
            
            
            NavigationView {
                CompareView(savedUsersVM: savedUsersVM)
                    .navigationTitle("Compare")
            }
            .tabItem {
                Label("Compare", systemImage: "chart.bar.xaxis")
            }
            .navigationViewStyle(StackNavigationViewStyle())

            
            NavigationView {
                FriendsView(savedUsersVM: savedUsersVM)
                    .navigationTitle("Friends")
            }
            .tabItem {
                Label("Friends", systemImage: "person.2")
            }
            .navigationViewStyle(StackNavigationViewStyle())

            NavigationView {
                ScrollView {
                    SearchView()
                }
                .navigationTitle("Search")
                .background(AppTheme.shared.backgroundColor(in: colorScheme))
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            .navigationViewStyle(StackNavigationViewStyle())

        }

    }
}

#Preview {
    ContentView()
}

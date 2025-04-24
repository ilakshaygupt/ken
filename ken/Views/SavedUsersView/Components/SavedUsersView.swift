//
//  SavedUsersView.swift
//  ken
//
//  Created by Lakshay Gupta on 16/04/25.
//



import SwiftUI
struct SavedUsersView: View {
    @ObservedObject var savedUsersVM: SavedUsersViewModel
    @ObservedObject var leetCodeVM: LeetCodeViewModel
    
    var body: some View {
        List {
            ForEach(savedUsersVM.savedUsernames, id: \.self) { username in
                NavigationLink(destination: UserDetailView(username: username, leetCodeVM: leetCodeVM)) {
                    UserRowView(username: username, leetCodeVM: leetCodeVM)
                        .swipeActions {
                            Button(role: .destructive) {
                                savedUsersVM.removeUsername(username)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .onAppear {
            savedUsersVM.savedUsernames.forEach { username in
                leetCodeVM.fetchData(for: username)
            }
        }
    }
}

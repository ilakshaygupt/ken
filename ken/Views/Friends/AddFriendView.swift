//
//  AddFriendView.swift
//  ken
//
//  Created by Lakshay Gupta on 04/05/25.
//
import SwiftUI


struct AddFriendView: View {
    @ObservedObject var leetCodeVM: LeetCodeViewModel
    @ObservedObject var savedUsersVM: SavedUsersViewModel
    @Binding var isPresented: Bool
    @Binding var username: String
    @State private var isLoading = false
    @State private var errorMessage: String?
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("LeetCode Username", text: $username)
                    .padding()
                    .background(AppTheme.shared.cardBackgroundColor(in: colorScheme))
                    .cornerRadius(8)
                    .disabled(isLoading)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                }
                
                Button(action: addFriend) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Add Friend")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(username.isEmpty || isLoading)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Add Friend")
            .navigationBarItems(
                trailing: Button("Cancel") {
                    isPresented = false
                }
            )
            .background(AppTheme.shared.backgroundColor(in: colorScheme))
        }
    }
    
    private func addFriend() {
        isLoading = true
        errorMessage = nil
        
        leetCodeVM.fetchData(for: username) { success in
            isLoading = false
            if success {
                savedUsersVM.addUsername(username)
                username = ""
                isPresented = false
            } else {
                errorMessage = "Could not find that LeetCode username. Please try again."
            }
        }
    }
} 

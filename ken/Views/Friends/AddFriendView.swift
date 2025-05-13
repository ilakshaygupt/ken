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
    @State private var isSuccessful = false
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with animation
                headerView
                
                // Main content
                VStack(spacing: 24) {
                    // Input field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("LeetCode username")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.leading, 4)
                        
                        HStack {
                            Image(systemName: "person")
                                .foregroundColor(.secondary)
                                .padding(.leading, 12)
                            
                            TextField("e.g. leetcoder123", text: $username)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .focused($isTextFieldFocused)
                                .padding(.vertical, 12)
                                .submitLabel(.go)
                                .onSubmit {
                                    if !username.isEmpty {
                                        addFriend()
                                    }
                                }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(errorMessage != nil ? Color.red.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 1)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(AppTheme.shared.cardBackgroundColor(in: colorScheme))
                                )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        if let errorMessage = errorMessage {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.circle")
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                                
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            .padding(.leading, 4)
                            .transition(.opacity)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Add button
                    Button(action: addFriend) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Add Friend")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .opacity(username.isEmpty || isLoading ? 0.5 : 1.0)
                        )
                        .cornerRadius(12)
                        .shadow(color: Color.blue.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                    .padding(.horizontal, 20)
                    .disabled(username.isEmpty || isLoading)
                    
                    // Success animation overlay
                    if isSuccessful {
                        SuccessView()
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    Spacer()
                }
                .padding(.top, 20)
            }
            .background(AppTheme.shared.backgroundColor(in: colorScheme))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                }
                .foregroundColor(.blue)
            )
            .onAppear {
                isTextFieldFocused = true
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue.opacity(0.4)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: Color.blue.opacity(0.2), radius: 8, x: 0, y: 4)
                
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            .padding(.top, 32)
            
            VStack(spacing: 8) {
                Text("Add a Friend")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Connect with friends to compare progress")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 10)
    }
    
    private func addFriend() {
        isLoading = true
        errorMessage = nil
        withAnimation {
            errorMessage = nil
        }
        
        // Close keyboard
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        leetCodeVM.fetchData(for: username) { success in
            if success {
                withAnimation(.spring()) {
                    isSuccessful = true
                }
                savedUsersVM.addUsername(username)
                username = ""
                
                // Delay dismissal to show success animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    isPresented = false
                    isSuccessful = false
                }
            } else {
                withAnimation {
                    errorMessage = "Could not find that LeetCode username"
                }
            }
            isLoading = false
        }
    }
}

struct SuccessView: View {
    @State private var scale: CGFloat = 0.5
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(scale)
                .onAppear {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        scale = 1.0
                    }
                }
                
                Text("Friend Added!")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
    }
}
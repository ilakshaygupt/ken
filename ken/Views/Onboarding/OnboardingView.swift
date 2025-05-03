//
//  OnboardingView.swift
//  ken
//
//  Created by Claude on 25/07/25.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var leetCodeVM = LeetCodeViewModel()
    @ObservedObject var savedUsersVM: SavedUsersViewModel
    @State private var username = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isComplete = false
    @AppStorage("has_completed_onboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Welcome to Ken")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Please enter your primary LeetCode username")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
                
                TextField("LeetCode Username", text: $username)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .disabled(isLoading)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                }
                
                Button(action: verifyAndSaveUsername) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Continue")
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
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $isComplete) {
            ContentView()
                .environmentObject(savedUsersVM)
        }
    }
    
    private func verifyAndSaveUsername() {
        isLoading = true
        errorMessage = nil
        
        // Try to fetch data to verify the username is valid
        leetCodeVM.fetchData(for: username) { success in
            isLoading = false
            if success {
                // Save as primary username
                savedUsersVM.setPrimaryUsername(username)
                
                // Mark onboarding as complete
                hasCompletedOnboarding = true
                
                // Show main app
                isComplete = true
            } else {
                errorMessage = "Could not find that LeetCode username. Please try again."
            }
        }
    }
} 
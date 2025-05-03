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
    
    // Define custom colors
    private let primaryColor = Color(red: 0.2, green: 0.5, blue: 0.9)
    private let secondaryColor = Color(red: 0.95, green: 0.95, blue: 0.97)
    private let accentColor = Color(red: 0.9, green: 0.3, blue: 0.3)
    private let backgroundColor = Color(red: 0.98, green: 0.98, blue: 1.0)
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(primaryColor)
                        .padding(.top, 40)
                    
                    Text("Welcome to Ken")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [primaryColor, accentColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Track and improve your LeetCode progress")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Enter your LeetCode username")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Username", text: $username)
                            .padding()
                            .background(secondaryColor)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(primaryColor.opacity(0.3), lineWidth: 1)
                            )
                            .disabled(isLoading)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                    }
                    .padding(.horizontal)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(accentColor)
                            .font(.subheadline)
                            .padding(.top, -10)
                    }
                    
                    Button(action: verifyAndSaveUsername) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Continue")
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            username.isEmpty ? primaryColor.opacity(0.4) : primaryColor
                        )
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: primaryColor.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .disabled(username.isEmpty || isLoading)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                        Text("Join the community of coders improving every day")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 20)
                }
                .padding()
            }
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
        
        
        leetCodeVM.fetchData(for: username) { success in
            isLoading = false
            if success {
                
                savedUsersVM.setPrimaryUsername(username)
                hasCompletedOnboarding = true
                isComplete = true
            } else {
                errorMessage = "Could not find that LeetCode username. Please try again."
            }
        }
    }
} 

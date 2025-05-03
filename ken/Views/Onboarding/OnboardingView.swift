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
    @State private var showErrorAlert = false
    @State private var showSuccessAlert = false
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
                    Image("icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
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
            .overlay(
                // Error popup
                ErrorPopupView(
                    isShowing: $showErrorAlert,
                    errorMessage: errorMessage ?? "An error occurred",
                    onDismiss: {
                        showErrorAlert = false
                        username = "" // Clear text field on error dismissal
                    }
                )
            )
            .overlay(
                // Success popup
                SuccessPopupView(
                    isShowing: $showSuccessAlert,
                    username: username,
                    onDismiss: {
                        showSuccessAlert = false
                        // Navigate to ContentView after success popup animation completes
                        isComplete = true
                    }
                )
            )
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
                // Save the username first
                savedUsersVM.setPrimaryUsername(username)
                hasCompletedOnboarding = true
                
                // Show success popup - BUT don't navigate yet
                showSuccessAlert = true
                
                // The navigation to ContentView will happen when the popup is dismissed
                // via the onDismiss callback in the SuccessPopupView overlay
            } else {
                errorMessage = "Could not find that LeetCode username. Please try again."
                showErrorAlert = true
            }
        }
    }
}

// Custom Error Popup View
struct ErrorPopupView: View {
    @Binding var isShowing: Bool
    let errorMessage: String
    let onDismiss: () -> Void
    
    // For animation
    @State private var offset: CGFloat = 1000
    
    var body: some View {
        ZStack {
            if isShowing {
                // Semi-transparent background
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismissPopup()
                    }
                
                // Error popup card
                VStack(spacing: 20) {
                    // Error icon
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                        .padding(.top, 25)
                    
                    // Error title
                    Text("Oops!")
                        .font(.system(size: 22, weight: .bold))
                    
                    // Error message
                    Text(errorMessage)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .foregroundColor(.secondary)
                    
                    // Dismiss button
                    Button(action: dismissPopup) {
                        Text("Try Again")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 25)
                }
                .frame(width: 300)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(20)
                .shadow(radius: 20)
                .offset(y: offset)
                .onAppear {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        offset = 0
                    }
                }
            }
        }
        .animation(.easeInOut, value: isShowing)
    }
    
    private func dismissPopup() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            offset = 1000
        }
        
        // Slight delay before fully dismissing to allow animation to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onDismiss()
        }
    }
}

// Update the SuccessPopupView to fix animation and timing issues
struct SuccessPopupView: View {
    @Binding var isShowing: Bool
    let username: String
    let onDismiss: () -> Void
    
    // For animation
    @State private var offset: CGFloat = 1000
    @State private var checkmarkScale: CGFloat = 0.1
    @State private var rotationDegrees: Double = 0
    @State private var confettiCounter = 0
    
    var body: some View {
        ZStack {
            if isShowing {
                // Semi-transparent background
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                // Success popup card
                VStack(spacing: 20) {
                    // Success checkmark with animation
                    ZStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                            .scaleEffect(checkmarkScale)
                            .rotationEffect(.degrees(rotationDegrees))
                    }
                    .padding(.top, 25)
                    
                    // Success title
                    Text("Welcome!")
                        .font(.system(size: 22, weight: .bold))
                    
                    // Success message
                    VStack(spacing: 8) {
                        Text("Username verified successfully")
                            .font(.body)
                            .multilineTextAlignment(.center)
                        
                        Text("Hi, \(username)!")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 20)
                    
                    // Confetti or celebration effect
                    HStack {
                        ForEach(0..<5) { index in
                            Image(systemName: "star.fill")
                                .foregroundColor([.yellow, .orange, .red, .blue, .purple][index % 5])
                                .font(.system(size: 24))
                                .offset(y: confettiCounter % 2 == 0 ? -5 : 5)
                                .animation(
                                    Animation.easeInOut(duration: 0.5)
                                        .repeatCount(5, autoreverses: true)
                                        .delay(Double(index) * 0.1),
                                    value: confettiCounter
                                )
                        }
                    }
                    
                    // Continue button
                    Button(action: dismissPopup) {
                        Text("Let's Go!")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 25)
                }
                .frame(width: 300)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(20)
                .shadow(radius: 20)
                .offset(y: offset)
                .onAppear {
                    // Animate the popup sliding in
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        offset = 0
                    }
                    
                    // Animate the checkmark
                    withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.3)) {
                        checkmarkScale = 1.0
                        rotationDegrees = 360
                    }
                    
                    // Start confetti animation
                    confettiCounter = 1
                    
                    // Auto-dismiss after a longer delay (3.5 seconds)
                    // This gives users time to see the success animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                        dismissPopup()
                    }
                }
            }
        }
    }
    
    private func dismissPopup() {
        // First animate the popup sliding away
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            offset = 1000
        }
        
        // Then wait for animation to complete before calling onDismiss
        // which will trigger navigation to ContentView
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            onDismiss()
        }
    }
} 

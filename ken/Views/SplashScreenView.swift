//
//  SplashScreenView.swift
//  ken
//
//  Created by Lakshay Gupta on 04/05/25.
//


import SwiftUI

struct SplashScreenView: View {
    @Binding var hasCompletedOnboarding: Bool
    @ObservedObject var savedUsersVM: SavedUsersViewModel
    
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive {
            if hasCompletedOnboarding {
                ContentView()
                    .environmentObject(savedUsersVM)
            } else {
                OnboardingView(savedUsersVM: savedUsersVM)
            }
        } else {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                VStack {
                    Image("icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5)
                    
                    Text("KEN")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.blue)
                        .padding(.top, 20)
                    
                    Text("Track your LeetCode progress")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.top, 5)
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 1.0
                        self.opacity = 1.0
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
            }
        }
    }
} 

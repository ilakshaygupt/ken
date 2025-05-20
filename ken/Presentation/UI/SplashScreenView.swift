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
    @Environment(\.colorScheme) private var colorScheme

    @State private var showLogo = false
    @State private var showTitle = false
    @State private var showImages = false
    @State private var isActive = false

    private var backgroundColor: Color {
        AppTheme.shared.backgroundColor(in: colorScheme)
    }
    
    var body: some View {
        if isActive {
            if hasCompletedOnboarding {
                ContentView().environmentObject(savedUsersVM)
            } else {
                OnboardingView(savedUsersVM: savedUsersVM)
            }
        } else {
            ZStack {
                backgroundColor.ignoresSafeArea()

                GeometryReader { geometry in
                    ZStack {
                        VStack(spacing: 16) {
                            Image("icon")
                                .resizable()
                                .frame(width: 200, height: 200)
                                .opacity(showLogo ? 1 : 0)
                                .offset(y: showLogo ? 0 : -100)
                                .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.3), value: showLogo)

                            Text("KenCode")
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .opacity(showTitle ? 1 : 0)
                                .offset(y: showTitle ? 0 : 60)
                                .animation(.easeOut(duration: 0.6).delay(0.8), value: showTitle)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .onAppear {
                showLogo = true
                showTitle = true
                showImages = true

                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}


#Preview {
    SplashScreenView(
        hasCompletedOnboarding: .constant(false),
        savedUsersVM: SavedUsersViewModel()
    )
}

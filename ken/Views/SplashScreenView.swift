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

    @State private var showLogo = false
    @State private var showTitle = false
    @State private var showImages = false
    @State private var isActive = false

    var body: some View {
        if isActive {
            if hasCompletedOnboarding {
                ContentView().environmentObject(savedUsersVM)
            } else {
                OnboardingView(savedUsersVM: savedUsersVM)
            }
        } else {
            ZStack {
                Color.black.ignoresSafeArea()

                GeometryReader { geometry in
                    ZStack {
                        // Corner images
                        Image("icon")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .opacity(showImages ? 1 : 0)
                            .position(x: showImages ? 60 : -40,
                                      y: showImages ? 60 : -40)
                            .animation(.easeOut(duration: 0.8).delay(1.0), value: showImages)

                        Image("RatingGraph")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .opacity(showImages ? 1 : 0)
                            .position(x: showImages ? geometry.size.width - 60 : geometry.size.width + 40,
                                      y: showImages ? 60 : -40)
                            .animation(.easeOut(duration: 0.8).delay(1.1), value: showImages)

                        Image("icon")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .opacity(showImages ? 1 : 0)
                            .position(x: showImages ? 60 : -40,
                                      y: showImages ? geometry.size.height - 60 : geometry.size.height + 40)
                            .animation(.easeOut(duration: 0.8).delay(1.2), value: showImages)

                        Image("icon")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .opacity(showImages ? 1 : 0)
                            .position(x: showImages ? geometry.size.width - 60 : geometry.size.width + 40,
                                      y: showImages ? geometry.size.height - 60 : geometry.size.height + 40)
                            .animation(.easeOut(duration: 0.8).delay(1.3), value: showImages)

                        VStack(spacing: 16) {
                            Image("icon")
                                .resizable()
                                .frame(width: 120, height: 120)
                                .opacity(showLogo ? 1 : 0)
                                .offset(y: showLogo ? 0 : -100)
                                .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.3), value: showLogo)

                            Text("KEN")
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
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

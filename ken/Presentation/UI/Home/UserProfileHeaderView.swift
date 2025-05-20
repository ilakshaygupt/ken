//
//  UserProfileHeaderView.swift
//  ken
//
//  Created by Lakshay Gupta on 20/05/25.
//

import SwiftUI

struct UserProfileHeaderView: View {
    let username: String
    let userProfile: UserProfile?
    let userStats: UserStats?
    let animate: Bool
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var cardBackgroundColor: Color {
        AppTheme.shared.cardBackgroundColor(in: colorScheme)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome back!")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .opacity(animate ? 1 : 0)
                        .offset(y: animate ? 0 : -20)
                    
                    if let userProfile = userProfile {
                        Text(userProfile.realName ?? username)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)
                            .opacity(animate ? 1 : 0)
                            .scaleEffect(animate ? 1 : 0.8)
                        
                        Text("@\(username)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .opacity(animate ? 1 : 0)
                            .offset(y: animate ? 0 : 10)
                    } else {
                        Text(username)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)
                            .opacity(animate ? 1 : 0)
                            .scaleEffect(animate ? 1 : 0.8)
                    }
                }
                
                Spacer()
                
                UserAvatarView(
                    userProfile: userProfile,
                    animate: animate
                )
            }
            
            if let stats = userStats {
                Divider()
                    .opacity(animate ? 1 : 0)
                
                HStack(spacing: 20) {
                    // Problems Solved
                    StatItemView(
                        value: "\(stats.totalSolved)",
                        label: "Problems",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                    
                    Divider()
                        .frame(height: 40)
                    
                    StatItemView(
                        value: "\(stats.ranking ?? 0)",
                        label: "Rating",
                        icon: "star.fill",
                        color: .yellow
                    )
                }
                .padding(.vertical, 8)
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : 20)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(cardBackgroundColor)
        )
        .padding(.horizontal, 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: animate)
    }
}

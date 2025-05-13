//
//  FriendRowView.swift
//  ken
//
//  Created by Lakshay Gupta on 04/05/25.
//
import SwiftUI

struct FriendRowView: View {
    let username: String
    @ObservedObject var leetCodeVM: LeetCodeViewModel
    @Environment(\.colorScheme) var colorScheme
    
    private var profileColor: Color {
        let hash = username.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        let hue = Double(hash % 360) / 360.0
        return Color(hue: hue, saturation: 0.7, brightness: 0.9)
    }

    var body: some View {
        HStack(spacing: 14) {
            // Profile icon
            Circle()
                .fill(LinearGradient(gradient: Gradient(colors: [profileColor, profileColor.opacity(0.7)]),
                                     startPoint: .topLeading,
                                     endPoint: .bottomTrailing))
                .frame(width: 44, height: 44)
                .overlay(
                    Text(String(username.prefix(1)).uppercased())
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(username)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)

                if let stats = leetCodeVM.userStats[username] {
                    HStack(spacing: 10) {
                        StatIcon(value: stats.totalSolved, icon: "checkmark.circle.fill", color: .green)
                        StatIcon(value: stats.ranking ?? 0, icon: "trophy.fill", color: .blue)

                        if let calendar = leetCodeVM.userCalendars[username] {
                            StatIcon(value: calendar.streak, icon: "flame.fill", color: .orange)
                        }
                    }
                } else {
                    HStack(spacing: 6) {
                        ProgressView()
                            .scaleEffect(0.6)
                        Text("Loading...")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13))
                .foregroundColor(.gray.opacity(0.4))
        }
        .padding(.vertical, 8)
    }
}

struct StatIcon: View {
    let value: Int
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 12))

            Text(formattedValue)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(color.opacity(0.1))
        .cornerRadius(6)
    }

    private var formattedValue: String {
        if value >= 10000 {
            return String(format: "%.1fk", Double(value) / 1000)
        } else if value >= 1000 {
            return String(format: "%.0fk", Double(value) / 1000)
        } else {
            return "\(value)"
        }
    }
}

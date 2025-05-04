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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(username)
                .font(.headline)
                .foregroundColor(.primary)
            
            if let stats = leetCodeVM.userStats[username] {
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 12))
                        
                        Text("\(stats.totalSolved) solved")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 12))
                        
                        Text("\(stats.ranking ?? 0) rank")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let calendar = leetCodeVM.userCalendars[username] {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                                .font(.system(size: 12))
                            
                            Text("\(calendar.streak) streak")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            } else {
                HStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                        .scaleEffect(0.8)
                    
                    Text("Loading stats...")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    
    
}

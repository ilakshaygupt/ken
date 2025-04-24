//
//  UserRowView.swift
//  ken
//
//  Created by Lakshay Gupta on 24/04/25.
//

import SwiftUI
struct UserRowView: View {
    let username: String
    @ObservedObject var leetCodeVM: LeetCodeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(username)
                .font(.headline)
            
            if let stats = leetCodeVM.userStats[username] {
                HStack {
                    Text("Solved: \(stats.totalSolved)")
                        .foregroundColor(.secondary)
                   
                }
                .font(.subheadline)
            }
        }
        .padding(.vertical, 4)
    }
}

//
//  StatsView.swift
//  ken
//
//  Created by Lakshay Gupta on 31/01/25.
//
import SwiftUI
import Combine
import WidgetKit



struct StatsView: View {
    let stats: LeetCode.UserStats
    
    var body: some View {
        VStack(spacing: 16) {
            StatCard(title: "Total Solved", value: stats.totalSolved)
            
            HStack(spacing: 12) {
                StatCard(title: "Easy", value: stats.easySolved)
                    .foregroundColor(.green)
                StatCard(title: "Medium", value: stats.mediumSolved)
                    .foregroundColor(.orange)
                StatCard(title: "Hard", value: stats.hardSolved)
                    .foregroundColor(.red)
            }
        }
    }
}

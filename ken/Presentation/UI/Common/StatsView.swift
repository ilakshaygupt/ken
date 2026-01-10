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
    let stats: UserStats
    
    var body: some View {
        VStack(spacing: UIConstants.spacing) {
            StatCard(title: "Total Solved", value: stats.totalSolved)
            
            HStack(spacing: UIConstants.itemSpacing) {
                StatCard(title: "Easy", value: stats.easySolved)
                    .foregroundColor(Color(hex: "1cbbba"))
                StatCard(title: "Medium", value: stats.mediumSolved)
                    .foregroundColor(.orange)
                StatCard(title: "Hard", value: stats.hardSolved)
                    .foregroundColor(.red)
            }
        }
    }
}

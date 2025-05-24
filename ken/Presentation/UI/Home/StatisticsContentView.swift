//
//  StatisticsContentView.swift
//  ken
//
//  Created by Lakshay Gupta on 20/05/25.
//
import SwiftUI


struct StatisticsContentView: View {
    let stats: UserStats
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            HStack(alignment: .center, spacing: 24) {
                MultiArcProgressView(
                    easyProgress: Double(stats.easySolved) / 873,
                    mediumProgress: Double(stats.mediumSolved) / 1829,
                    hardProgress: Double(stats.hardSolved) / 824,
                    lineWidth: 12,
                    totalQuestions: stats.totalProblems,
                    solvedQuestion: stats.totalSolved
                )
                .frame(width: UIScreen.main.bounds.width * 0.3, height: 124)
                
                Divider()
                
                VStack(alignment: .leading) {
                    Spacer()
                    DifficultyStatView(
                        label: "Easy",
                        solved: stats.easySolved,
                        total: stats.easyTotal,
                        color: Color(hex: "1cbbba")
                    )
                    Spacer()
                    DifficultyStatView(
                        label: "Med",
                        solved: stats.mediumSolved,
                        total: stats.mediumTotal,
                        color: .yellow
                    )
                    Spacer()
                    DifficultyStatView(
                        label: "Hard",
                        solved: stats.hardSolved,
                        total: stats.hardTotal,
                        color: .red
                    )
                    Spacer()
                }
            }
        }
    }
}

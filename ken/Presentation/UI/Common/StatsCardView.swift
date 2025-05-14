//
//  StatsCardView.swift
//  ken
//
//  Created by Lakshay Gupta on 03/05/25.
//
import SwiftUI

struct StatsCardView: View {
    let stats: UserStats
    @State private var animate = false
    @Environment(\.colorScheme) private var colorScheme
    
    private var cardBackgroundColor: Color {
        AppTheme.shared.cardBackgroundColor(in: colorScheme)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Solved Problems")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            HStack(spacing: 16) {
                StatPieChart(
                    total: stats.totalSolved,
                    maximum: stats.totalProblems,
                    title: "Total",
                    color: .blue,
                    animate: animate
                )
                
                Divider()
                    .frame(height: 100)
                
                VStack(spacing: 20) {
                    DifficultyBar(
                        solved: stats.easySolved,
                        total: stats.easyTotal,
                        title: "Easy",
                        color: .green,
                        animate: animate
                    )
                    
                    DifficultyBar(
                        solved: stats.mediumSolved,
                        total: stats.mediumTotal,
                        title: "Medium",
                        color: .orange,
                        animate: animate
                    )
                    
                    DifficultyBar(
                        solved: stats.hardSolved,
                        total: stats.hardTotal,
                        title: "Hard",
                        color: .red,
                        animate: animate
                    )
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(cardBackgroundColor)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
            )
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    animate = true
                }
            }
        }
    }
}

//
//  ContributionWeeksView.swift
//  ken
//
//  Created by Lakshay Gupta on 31/01/25.
//


import SwiftUI
struct ContributionWeeksView: View {
    let weeks: [[LeetCode.UserCalendar.DailyContribution?]]
    let monthLabels: [(String, Int)]
    @Binding var hoveredContribution: LeetCode.UserCalendar.DailyContribution?
    
    private let cellSize: CGFloat = 10
    private let spacing: CGFloat = 3
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: spacing) {
                ForEach(Array(weeks.enumerated()), id: \.offset) { weekIndex, week in
                    WeekColumnView(
                        week: week
                    )
                    
                    if monthLabels.contains(where: { $0.1 == weekIndex }) {
                        MonthDivider()
                    }
                }
            }
        }
    }
} 

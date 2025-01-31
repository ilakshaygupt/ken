//
//  WeekColumnView.swift
//  ken
//
//  Created by Lakshay Gupta on 31/01/25.
//


import SwiftUI
struct WeekColumnView: View {
    let week: [LeetCode.UserCalendar.DailyContribution?]
    private let spacing: CGFloat = 3
    private let cellSize: CGFloat = 10
    
    var body: some View {
        VStack(spacing: spacing) {
            ForEach(Array(week.enumerated()), id: \.offset) { index, contribution in
                if let contribution = contribution {
                    ContributionCell(
                        contribution: contribution,
                        size: cellSize
                    )
                } else {
                    Color.clear
                        .frame(width: cellSize, height: cellSize)
                }
            }
        }
    }
}

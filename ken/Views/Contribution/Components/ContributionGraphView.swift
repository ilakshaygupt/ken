//
//  ContributionGraphView.swift
//  ken
//
//  Created by Lakshay Gupta on 31/01/25.
//


import SwiftUI

struct ContributionGraphView: View {
    let contributions: [DailyContribution]
    let monthsToShow: Int
    
    @State private var hoveredContribution: DailyContribution?
    @State private var hoverLocation: CGPoint = .zero
    @Environment(\.colorScheme) private var colorScheme
    
    private var cardBackgroundColor: Color {
        AppTheme.shared.cardBackgroundColor(in: colorScheme)
    }
    
    init(contributions: [DailyContribution], monthsToShow: Int = 12) {
        self.contributions = contributions
        self.monthsToShow = monthsToShow
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Contributions")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Swipe to see more months")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, -8)
             
            ContributionGridView(
                contributions: contributions, 
                hoveredContribution: $hoveredContribution,
                monthsToShow: monthsToShow)
            
            ContributionsColorsHelpView()
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(12)
        .shadow(radius: 2)
        .overlay(
            Group {
                if let contribution = hoveredContribution {
                    ContributionTooltip(contribution: contribution)
                        .position(hoverLocation)
                }
            }
        )
    }
} 

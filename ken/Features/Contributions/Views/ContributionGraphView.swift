//
//  ContributionGraphView.swift
//  ken
//
//  Created by Lakshay Gupta on 31/01/25.
//


import SwiftUI

struct ContributionGraphView: View {
    let contributions: [LeetCode.UserCalendar.DailyContribution]
    
    @State private var hoveredContribution: LeetCode.UserCalendar.DailyContribution?
    @State private var hoverLocation: CGPoint = .zero
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Contributions")
                .font(.headline)
                .foregroundColor(.primary)
             
            
            ContributionGridView(
                contributions: contributions)
            
            ContributionLegendView()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .overlay(
            Group {
                if let contribution = hoveredContribution {
                    ContributionTooltip(contribution: contribution)
                }
            }
        )
    }
} 

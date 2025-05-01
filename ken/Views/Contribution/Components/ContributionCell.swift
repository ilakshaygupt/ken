//
//  ContributionCell.swift
//  ken
//
//  Created by Lakshay Gupta on 31/01/25.
//


import SwiftUI

struct ContributionCell: View {
    let contribution: DailyContribution
    let size: CGFloat
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var contributionColor: Color {
        let intensity = min(1.0, Double(contribution.count) / 5.0)
        if colorScheme == .dark {
            return Color.green.opacity(0.2 + (intensity * 0.8))
        } else {
            return Color.green.opacity(0.1 + (intensity * 0.9))
        }
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(contribution.count > 0 ? contributionColor : Color.primary.opacity(0.05))
            .frame(width: size, height: size)
    }
}

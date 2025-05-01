//
//  ContributionTooltip.swift
//  ken
//
//  Created by Lakshay Gupta on 31/01/25.
//


import SwiftUI
struct ContributionTooltip: View {
    let contribution: DailyContribution
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            let dateFormatter = DateFormatter()
            Text("\(dateFormatter.string(from: contribution.date))")
                .font(.caption)
                .bold()
            Text("\(contribution.count) submissions")
                .font(.caption2)
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 4)
    }
} 

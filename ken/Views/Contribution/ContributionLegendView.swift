//
//  ContributionLegendView.swift
//  ken
//
//  Created by Lakshay Gupta on 31/01/25.
//


import SwiftUI
struct ContributionLegendView: View {
    private let cellSize: CGFloat = 10
    
    var body: some View {
        HStack(spacing: 16) {
            Text("Less")
                .font(.caption)
                .foregroundColor(.secondary)
            HStack(spacing: 2) {
                ForEach([0, 1, 3, 5, 7], id: \.self) { count in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(ContributionColors.color(for: count))
                        .frame(width: cellSize, height: cellSize)
                }
            }
            Text("More")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
} 

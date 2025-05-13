//
//  DifficultyBar.swift
//  ken
//
//  Created by Lakshay Gupta on 03/05/25.
//
import SwiftUI


struct DifficultyBar: View {
    let solved: Int
    let total: Int
    let title: String
    let color: Color
    let animate: Bool
    
    private var percentage: CGFloat {
        total > 0 ? CGFloat(solved) / CGFloat(total) : 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(solved)/\(total)")
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            
            ZStack(alignment: .leading) {
                // Background
                Rectangle()
                    .fill(color.opacity(0.2))
                    .frame(height: 8)
                    .cornerRadius(4)
                
                // Progress
                Rectangle()
                    .fill(color)
                    .frame(width: animate ? max(CGFloat(percentage) * UIScreen.main.bounds.width * 0.5, 4) : 0, height: 8)
                    .cornerRadius(4)
            }
        }
    }
}

//
//  StatPieChart.swift
//  ken
//
//  Created by Lakshay Gupta on 03/05/25.
//

import SwiftUI

struct StatPieChart: View {
    let total: Int
    let maximum: Int
    let title: String
    let color: Color
    let animate: Bool
    
    private var percentage: Double {
        maximum > 0 ? Double(total) / Double(maximum) : 0
    }
    
    var body: some View {
        VStack {
            ZStack {
                
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 10)
                
                
                Circle()
                    .trim(from: 0, to: animate ? CGFloat(percentage) : 0)
                    .stroke(color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                
                VStack {
                    Text("\(total)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("/ \(maximum)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 100, height: 100)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
}

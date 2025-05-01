//
//  DifficultyStatView.swift
//  ken
//
//  Created by Lakshay Gupta on 25/04/25.
//

import SwiftUI

struct DifficultyStatView: View {
    let label: String
    let solved: Int
    let total: Int
    let color: Color
    
    var body: some View {
        HStack(spacing:4) {
            Text(label)
                .font(.system(size: 13, weight: .medium,design: .monospaced))
                .foregroundColor(color)
            
                
            
            Spacer()
            
            Text("\(solved)")
                
                .font(.system(size: 13, weight: .bold,design: .monospaced))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            
            Text("/")
                .font(.system(size: 13,design: .monospaced))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
                Text("\(total)")
                    .font(.system(size: 12,design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            
        }
    }
}

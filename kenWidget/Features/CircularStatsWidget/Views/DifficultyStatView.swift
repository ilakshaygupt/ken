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
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(color)
            
            Spacer()
            
            Text("\(solved)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.primary)
            
            Text("/\(total)")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
    }
}

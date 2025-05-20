//
//  StatItemView.swift
//  ken
//
//  Created by Lakshay Gupta on 20/05/25.
//

import SwiftUI

struct StatItemView: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 20))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

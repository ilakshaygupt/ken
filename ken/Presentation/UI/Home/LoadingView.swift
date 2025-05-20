//
//  LoadingView.swift
//  ken
//
//  Created by Lakshay Gupta on 20/05/25.
//
import SwiftUI


struct LoadingView: View {
    let message: String
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var cardBackgroundColor: Color {
        AppTheme.shared.cardBackgroundColor(in: colorScheme)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            
            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 250)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(cardBackgroundColor)
        )
    }
}

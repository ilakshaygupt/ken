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
        VStack(spacing: UIConstants.spacing) {
            ProgressView()
                .scaleEffect(1.5)
                .padding(UIConstants.padding)
            
            Text(message)
                .font(UIConstants.headlineFont)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 250)
        .background(
            RoundedRectangle(cornerRadius: UIConstants.cornerRadiusXLarge)
                .fill(cardBackgroundColor)
        )
    }
}

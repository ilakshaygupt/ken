//
//  NoPrimaryUserView.swift
//  ken
//
//  Created by Lakshay Gupta on 20/05/25.
//
import SwiftUI


struct NoPrimaryUserView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    private var cardBackgroundColor: Color {
        AppTheme.shared.cardBackgroundColor(in: colorScheme)
    }
    
    var body: some View {
        VStack(spacing: UIConstants.spacingXLarge) {
            Image(systemName: "person.fill.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.blue.opacity(0.7))
            
            Text("No Primary Username Set")
                .font(UIConstants.title2Font)
                .fontWeight(.bold)
            
            Text("Please set a primary username in your profile settings.")
                .font(UIConstants.bodyFont)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, UIConstants.paddingXLarge)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .background(
            RoundedRectangle(cornerRadius: UIConstants.cornerRadiusXLarge)
                .fill(cardBackgroundColor)
        )
    }
}

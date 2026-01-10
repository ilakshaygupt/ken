//
//  AppTheme.swift
//  ken
//
//  Created by Lakshay on 25/07/25.
//

import SwiftUI

struct AppTheme {
    static let shared = AppTheme()
    
    // MARK: - Background Colors
    
    func backgroundColor(in colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: "141414") : Color(UIColor.systemGray6)
    }
    
    func cardBackgroundColor(in colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: "282828") : Color(.systemBackground)
    }
    
    // MARK: - Card Styling
    
    func cardStyle(in colorScheme: ColorScheme) -> some ViewModifier {
        CardStyleModifier(
            backgroundColor: cardBackgroundColor(in: colorScheme),
            cornerRadius: UIConstants.cornerRadius,
            shadowRadius: UIConstants.shadowRadius,
            shadowOpacity: UIConstants.shadowOpacity
        )
    }
    
    // MARK: - Section Styling
    
    func sectionStyle(in colorScheme: ColorScheme) -> some ViewModifier {
        SectionStyleModifier(
            backgroundColor: cardBackgroundColor(in: colorScheme),
            cornerRadius: UIConstants.cornerRadius,
            padding: UIConstants.cardPadding
        )
    }
}

// MARK: - View Modifiers

struct CardStyleModifier: ViewModifier {
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    let shadowOpacity: Double
    
    func body(content: Content) -> some View {
        content
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(
                color: Color.black.opacity(shadowOpacity),
                radius: shadowRadius,
                x: 0,
                y: 1
            )
    }
}

struct SectionStyleModifier: ViewModifier {
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let padding: CGFloat
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
    }
}

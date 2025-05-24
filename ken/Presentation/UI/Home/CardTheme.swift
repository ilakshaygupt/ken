//
//  CardTheme.swift
//  ken
//
//  Created by Lakshay Gupta on 20/05/25.
//
import SwiftUI


struct CardTheme {
    let primaryGradient: [Color]
    let iconBackground: Color
    let cardBackground: Color
    
    static let stats = CardTheme(
        primaryGradient: [Color.blue, Color.blue.opacity(0.7)],
        iconBackground: .blue,
        cardBackground: Color("CardBackground")
    )
    
    static let yearly = CardTheme(
        primaryGradient: [Color.orange, Color.orange.opacity(0.7)],
        iconBackground: .orange,
        cardBackground: Color("CardBackground")
    )
    
    static let calendar = CardTheme(
        primaryGradient: [Color.indigo, Color.indigo.opacity(0.7)],
        iconBackground: .indigo,
        cardBackground: Color("CardBackground")
    )
}

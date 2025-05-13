//
//  ContributionColors.swift
//  ken
//
//  Created by Lakshay Gupta on 31/01/25.
//


import SwiftUI

extension Color {
    init(hex: String, opacity: Double = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue,opacity: opacity)
    }
}

enum ContributionColors {
    static func color(for count: Int) -> Color {
        switch count {
        case 0: return Color(hex: "2D2D2D")  // Darker gray for no activity
        case 1: return Color(hex: "196127")  // Light green
        case 2...3: return Color(hex: "239A3B") // Medium green
        case 4...6: return Color(hex: "2BBB4F") // Bright green
        default: return Color(hex: "3BDF58")  // Very bright green for high activity
        }
    }
}

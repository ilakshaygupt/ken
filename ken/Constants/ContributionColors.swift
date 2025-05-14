//
//  ContributionColors.swift
//  ken
//
//  Created by Lakshay Gupta on 31/01/25.
//


import SwiftUI

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

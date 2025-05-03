//
//  AppTheme.swift
//  ken
//
//  Created by Claude on 25/07/25.
//

import SwiftUI

struct AppTheme {
    
    static let shared = AppTheme()
    
    
    func backgroundColor(in colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: "141414") : Color(UIColor.systemGray6)
    }
    
    
    func cardBackgroundColor(in colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: "282828") : Color(.systemBackground)
    }
}

//
//  StatCard.swift
//  ken
//
//  Created by Lakshay Gupta on 31/01/25.
//
import SwiftUI
import Combine
import WidgetKit




struct StatCard: View {
    let title: String
    let value: Int
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: UIConstants.spacingSmall) {
            Text(title)
                .font(UIConstants.headlineFont)
                .foregroundColor(.secondary)
            Text("\(value)")
                .font(UIConstants.titleFont)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(UIConstants.padding)
        .background(AppTheme.shared.cardBackgroundColor(in: colorScheme))
        .cornerRadius(UIConstants.cornerRadius)
    }
}

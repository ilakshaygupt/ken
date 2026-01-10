//
//  CalendarView.swift
//  ken
//
//  Created by Lakshay Gupta on 31/01/25.
//


import SwiftUI
import Combine


struct CalendarView: View {
    let calendar: UserCalendar
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: UIConstants.spacing) {
            Text("Calendar Stats")
                .font(UIConstants.title2Font)
                .fontWeight(.bold)
            
            HStack(spacing: UIConstants.itemSpacing) {
                StatCard(title: "Current Streak", value: calendar.streak)
                    .foregroundColor(.blue)
                StatCard(title: "Active Days", value: calendar.totalActiveDays)
                    .foregroundColor(.green)
            }
            
            if !calendar.dccBadges.isEmpty {
                VStack(alignment: .leading, spacing: UIConstants.spacingSmall) {
                    Text("Badges")
                        .font(UIConstants.headlineFont)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: UIConstants.itemSpacing) {
                            ForEach(calendar.dccBadges, id: \.timestamp) { badge in
                                BadgeView(badge: badge)
                            }
                        }
                        .padding(.horizontal, UIConstants.paddingSmall / 2)
                    }
                }
            }
            
            if !calendar.activeYears.isEmpty {
                VStack(alignment: .leading, spacing: UIConstants.spacingSmall) {
                    Text("Active Years")
                        .font(UIConstants.headlineFont)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: UIConstants.spacingSmall) {
                            ForEach(calendar.activeYears, id: \.self) { year in
                                Text("\(year)")
                                    .padding(.horizontal, UIConstants.paddingMedium)
                                    .padding(.vertical, UIConstants.paddingSmall)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(UIConstants.cornerRadiusSmall)
                            }
                        }
                    }
                }
            }
            
            ContributionsView(contributions: calendar.contributions)
        }
        .modifier(AppTheme.shared.sectionStyle(in: colorScheme))
    }
}

//
//  CalendarView.swift
//  ken
//
//  Created by Lakshay Gupta on 31/01/25.
//


import SwiftUI
import Combine


struct CalendarView: View {
    let calendar: LeetCode.UserCalendar
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Calendar Stats")
                .font(.title2)
                .bold()
            
            HStack(spacing: 12) {
                StatCard(title: "Current Streak", value: calendar.streak)
                    .foregroundColor(.blue)
                StatCard(title: "Active Days", value: calendar.totalActiveDays)
                    .foregroundColor(.green)
            }
            
            if !calendar.dccBadges.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Badges")
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(calendar.dccBadges, id: \.timestamp) { badge in
                                BadgeView(badge: badge)
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
            }
            
            if !calendar.activeYears.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Active Years")
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(calendar.activeYears, id: \.self) { year in
                                Text("\(year)")
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            
            let contributions = LeetCode.UserCalendar.DailyContribution.parse(from: calendar.submissionCalendar)
            ContributionGraphView(contributions: contributions)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

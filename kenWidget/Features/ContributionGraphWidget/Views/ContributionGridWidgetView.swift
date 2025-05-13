//
//  ContributionGridView.swift
//  ken
//
//  Created by Lakshay Gupta on 21/02/25.
//

import SwiftUI

struct ContributionGridWidgetView: View {
    let contributions: [DailyContribution]
    
    private let cellSize: CGFloat = 11
    private let spacing: CGFloat = 3
    private let monthSpacing: CGFloat = 10
    private var monthsToShow: Int {
            widgetFamily == .systemSmall ? 1 : 3
        }

    @Environment(\.widgetFamily) private var widgetFamily
    
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 1
        return calendar
    }
    
    private var weekdayLabels: [String] {
        calendar.veryShortWeekdaySymbols 
    }
    
    
    private var monthlyContributions: [(String, [[DailyContribution?]])] {
        
        let today = Date()
        var result: [(String, [[DailyContribution?]])] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        
        for monthsAgo in (0..<monthsToShow).reversed() {
            guard let monthStart = calendar.date(byAdding: .month, value: -monthsAgo, to: today) else { continue }
            
            let monthStartComponents = calendar.dateComponents([.year, .month], from: monthStart)
            guard let firstDayOfMonth = calendar.date(from: monthStartComponents) else { continue }
            guard let firstDayOfNextMonth = calendar.date(byAdding: .month, value: 1, to: firstDayOfMonth) else { continue }
            
            let monthLabel = dateFormatter.string(from: monthStart)
            var monthWeeks: [[DailyContribution?]] = []
            var currentWeek: [DailyContribution?] = []
            
            let weekday = calendar.component(.weekday, from: firstDayOfMonth)
            if weekday > 1 {
                for _ in 1..<weekday {
                    currentWeek.append(nil)
                }
            }
            
            var currentDate = firstDayOfMonth
            while currentDate < firstDayOfNextMonth && currentDate <= today {
                if let contribution = contributions.first(where: { calendar.isDate($0.date, inSameDayAs: currentDate) }) {
                    currentWeek.append(contribution)
                } else {
                    currentWeek.append(DailyContribution(date: currentDate, count: 0))
                }
                
                if currentWeek.count == 7 {
                    monthWeeks.append(currentWeek)
                    currentWeek = []
                }
                
                guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
                currentDate = nextDate
            }
            
            if !currentWeek.isEmpty {
                while currentWeek.count < 7 {
                    currentWeek.append(nil)
                }
                monthWeeks.append(currentWeek)
            }
            
            result.append((monthLabel, monthWeeks))
        }
        
        return result
    }
    
    var body: some View {
            HStack(alignment: .top, spacing: monthSpacing) {
                ForEach(monthlyContributions, id: \.0) { month, weeks in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(month)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center) 
                        
                        VStack(alignment: .leading, spacing: spacing) {
                            ForEach(0..<7, id: \.self) { dayIndex in
                                HStack(spacing: spacing) {
                                    ForEach(weeks.indices, id: \.self) { weekIndex in
                                        if dayIndex < weeks[weekIndex].count,
                                           let contribution = weeks[weekIndex][dayIndex] {
                                            ContributionCell(
                                                contribution: contribution,
                                                size: cellSize
                                            )
                                            
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 2)
                                                    .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                                            )
                                        } else {
                                            Color.clear
                                                .frame(width: cellSize, height: cellSize)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
        }
            .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0))
    }
}

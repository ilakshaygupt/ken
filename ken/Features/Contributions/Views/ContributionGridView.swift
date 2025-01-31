//
//  ContributionGridView.swift
//  ken
//
//  Created by Lakshay Gupta on 31/01/25.
//



import SwiftUI

struct ContributionGridView: View {
    let contributions: [LeetCode.UserCalendar.DailyContribution]
    
    //
    private let cellSize: CGFloat = 12 
    private let spacing: CGFloat = 4 
    private let monthSpacing: CGFloat = 24 
    private let monthsToShow = 3
    
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 1
        return calendar
    }
    
    private var weekdayLabels: [String] {
        calendar.veryShortWeekdaySymbols 
    }
    
    
    private var monthlyContributions: [(String, [[LeetCode.UserCalendar.DailyContribution?]])] {
        
        let today = Date()
        var result: [(String, [[LeetCode.UserCalendar.DailyContribution?]])] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        
        for monthsAgo in (0..<monthsToShow).reversed() {
            guard let monthStart = calendar.date(byAdding: .month, value: -monthsAgo, to: today) else { continue }
            
            let monthStartComponents = calendar.dateComponents([.year, .month], from: monthStart)
            guard let firstDayOfMonth = calendar.date(from: monthStartComponents) else { continue }
            guard let firstDayOfNextMonth = calendar.date(byAdding: .month, value: 1, to: firstDayOfMonth) else { continue }
            
            let monthLabel = dateFormatter.string(from: monthStart)
            var monthWeeks: [[LeetCode.UserCalendar.DailyContribution?]] = []
            var currentWeek: [LeetCode.UserCalendar.DailyContribution?] = []
            
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
                    currentWeek.append(LeetCode.UserCalendar.DailyContribution(date: currentDate, count: 0))
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
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                Text("Contribution Activity")
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Text("Last 3 months")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 4)
            
            
            HStack(alignment: .top, spacing: monthSpacing) {
                
                VStack(alignment: .leading, spacing: spacing) {
                    Color.clear.frame(height: 18) 
                    ForEach(weekdayLabels.indices, id: \.self) { index in
                        Text(weekdayLabels[index])
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .frame(width: 20, alignment: .leading)
                    }
                }
                
                
                ForEach(monthlyContributions, id: \.0) { month, weeks in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(month)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
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
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
        )
    }
}

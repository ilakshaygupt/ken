//
//  ContributionGridView.swift
//  ken
//
//  Created by Lakshay Gupta on 31/01/25.
//



import SwiftUI

private struct ContributionColorSchemeKey: EnvironmentKey {
    static let defaultValue: ContributionColorScheme = .blue
}

enum ContributionColorScheme {
    case blue
    case green
}

extension EnvironmentValues {
    var contributionColorScheme: ContributionColorScheme {
        get { self[ContributionColorSchemeKey.self] }
        set { self[ContributionColorSchemeKey.self] = newValue }
    }
}

struct ContributionGridView: View {
    let contributions: [DailyContribution]
    @Binding var hoveredContribution: DailyContribution?

    
    private let cellSize: CGFloat = 11
    private let spacing: CGFloat = 3
    private let monthSpacing: CGFloat = 10  
    private let monthsToShow: Int
    private let monthWidth: CGFloat = 90

    
    
    @Environment(\.colorScheme) private var colorScheme
    
    
    
    init(contributions: [DailyContribution], hoveredContribution: Binding<DailyContribution?>, monthsToShow: Int = 3) {
           self.contributions = contributions
           self._hoveredContribution = hoveredContribution
           self.monthsToShow = monthsToShow
       }
    
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
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: true) {
                HStack(alignment: .top, spacing: monthSpacing) {
                    ForEach(Array(monthlyContributions.enumerated()), id: \.1.0) { index, element in
                        let month = element.0
                        let weeks = element.1
                        VStack(alignment: .leading, spacing: 2) {
                            Text(month)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                                .frame(maxWidth:.infinity,alignment: .center)
                                

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
                                                .onTapGesture {
                                                    hoveredContribution = contribution
                                                }

                                            } else {
                                                Color.clear
                                                    .frame(width: cellSize, height: cellSize)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .frame(width: monthWidth)
                        .id(index)
                    }
                }
                .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                .frame(minWidth: UIScreen.main.bounds.width - 40)
            }
            .onAppear {
                if let lastIndex = monthlyContributions.indices.last {
                    DispatchQueue.main.async {
                        withAnimation(.easeInOut(duration: 0.8)) {
                                     proxy.scrollTo(lastIndex, anchor: .trailing)
                                 }
                    }
                }
            }
        }
    }

}


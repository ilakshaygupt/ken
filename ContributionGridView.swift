struct ContributionGridView: View {
    let contributions: [CalendarDay]
    
    var body: some View {
        // Your existing grid implementation, but make sure to add an ID
        // to the rightmost month or day that we want to scroll to
        
        HStack(alignment: .top, spacing: 4) {
            // Assuming you have a structure like this showing months
            ForEach(groupedByMonth(), id: \.month) { monthData in
                VStack(alignment: .leading, spacing: 4) {
                    Text(monthLabel(for: monthData.month))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    // Your month visualization
                    // ...
                }
                // Add ID to the last month
                .id(isLastMonth(monthData.month) ? "lastMonth" : nil)
            }
        }
        .padding(.horizontal)
    }
    
    // Helper function to check if a month is the most recent one
    private func isLastMonth(_ month: Date) -> Bool {
        let sortedMonths = groupedByMonth().map(\.month).sorted()
        return month == sortedMonths.last
    }
    
    // Your existing helper methods
    private func groupedByMonth() -> [MonthData] {
        // Your existing code to group contributions by month
        // ...
    }
    
    private func monthLabel(for date: Date) -> String {
        // Your existing code to format month labels
        // ...
    }
} 
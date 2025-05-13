struct ContributionsView: View {
    let contributions: [CalendarDay]
    let monthsToShow: Int
    let scrollToEnd: Bool
    @State private var containerWidth: CGFloat = 0
    @State private var contentWidth: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { outerGeometry in
            ScrollView(.horizontal, showsIndicators: false) {
                ZStack(alignment: .leading) {
                    // Invisible spacer to measure content width
                    GeometryReader { geometry in
                        Color.clear.preference(
                            key: ContentWidthPreferenceKey.self,
                            value: geometry.size.width
                        )
                    }
                    
                    ContributionGridView(contributions: filteredContributions())
                        .padding(.horizontal)
                }
            }
            .onAppear {
                // Save container width for calculations
                containerWidth = outerGeometry.size.width
                
                // Only scroll to end if requested
                if scrollToEnd {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        // Calculate max scroll offset and animate to it
                        let maxOffset = max(0, contentWidth - containerWidth)
                        withAnimation {
                            scrollOffset = maxOffset
                        }
                    }
                }
            }
            .onPreferenceChange(ContentWidthPreferenceKey.self) { width in
                contentWidth = width
            }
            // Apply the scroll offset
            .environment(\.horizontalScrollOffset, scrollOffset)
        }
    }
    
    private func filteredContributions() -> [CalendarDay] {
        // Your existing filtering logic
        // ...
    }
}

// Preference key to get content width
struct ContentWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// Environment key for passing scroll offset
private struct HorizontalScrollOffsetKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

extension EnvironmentValues {
    var horizontalScrollOffset: CGFloat {
        get { self[HorizontalScrollOffsetKey.self] }
        set { self[HorizontalScrollOffsetKey.self] = newValue }
    }
} 
} 
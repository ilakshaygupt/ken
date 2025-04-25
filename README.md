# Ken - LeetCode Activity Widget




Ken is an iOS widget that displays your LeetCode contribution activity right on your home screen. Track your coding consistency with a beautiful, GitHub-style contribution graph.

## Features

- 📊 Visual contribution graph showing last 3 months of activity
- 🏆 Current streak tracking
- 📱 iOS widget in medium and large sizes
- 🌓 Supports both light and dark mode
- 🔄 Auto-refreshing data


## Screenshots


<p align="center">
  <img src="https://github.com/user-attachments/assets/0415e998-cce4-4137-a13b-1f4da37ed750" width="33%">
  <img src="https://github.com/user-attachments/assets/6af88fee-620a-410d-8092-2e1f88e331c0" width="33%">
  <img src="https://github.com/user-attachments/assets/3263d8b3-2b00-46c0-a9b1-42c87936da0e" width="33%">
</p>

<img src="https://github.com/user-attachments/assets/e14763b7-739b-4646-8a5e-9d82982aa130" >


### Built With

- SwiftUI for the UI framework
- WidgetKit for iOS widget functionality
- SwiftSoup for HTML parsing
- Combine for reactive programming

### Architecture

The project consists of two main targets:
- Main app (`ken.app`)
- Widget extension (`kenWidgetExtension.appex`)

Key components:

```swift
// LeetCode data models
struct UserStats {
    let totalSolved: Int
    let easySolved: Int
    let mediumSolved: Int
    let hardSolved: Int
    let acceptanceRate: Double
    let ranking: Int
}

struct UserCalendar {
    let activeYears: [Int]
    let streak: Int
    let totalActiveDays: Int
    let submissionCalendar: String
    let dccBadges: [Badge]
}
```

### Widget Configuration

The widget supports two sizes:
- Medium: Compact contribution graph
- Large: Full contribution graph with additional stats

### Color Scheme

The contribution graph uses a custom color palette based on activity level:


## Installation

1. Clone the repository
2. Open `ken.xcodeproj` in Xcode
3. Build and run the project
4. Add the widget to your home screen

## Requirements

- iOS 18.2+
- Xcode 16.2+
- Active LeetCode account

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- LeetCode for providing the user activity data
- GitHub for inspiration on the contribution graph design

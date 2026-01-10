import SwiftUI

struct UserStatsCardView: View {
    let stats: UserStats
    @Environment(\.colorScheme) private var colorScheme
    
    private var solvedPercentage: Double {
        stats.totalProblems > 0 ? Double(stats.totalSolved) / Double(stats.totalProblems) : 0
    }
    
    var body: some View {
        VStack(spacing: UIConstants.spacing) {
            // Header
            HStack {
                Text("LeetCode Progress")
                    .font(UIConstants.headlineFont)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let ranking = stats.ranking {
                    Text("Rank: \(ranking)")
                        .font(UIConstants.subheadlineFont)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, UIConstants.spacingSmall)
                        .padding(.vertical, UIConstants.paddingSmall / 2)
                        .background(Color.yellow.opacity(0.2))
                        .cornerRadius(UIConstants.cornerRadiusSmall)
                }
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: UIConstants.spacingSmall) {
                HStack {
                    Text("Total Problems Solved")
                        .font(UIConstants.subheadlineFont)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(stats.totalSolved) / \(stats.totalProblems)")
                        .font(UIConstants.subheadlineFont)
                        .foregroundColor(.primary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: geometry.size.width, height: 8)
                            .cornerRadius(UIConstants.paddingSmall / 2)
                        
                        Rectangle()
                            .fill(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing))
                            .frame(width: geometry.size.width * CGFloat(solvedPercentage), height: 8)
                            .cornerRadius(UIConstants.paddingSmall / 2)
                    }
                }
                .frame(height: 8)
            }
            
            // Difficulty breakdown
            HStack(spacing: UIConstants.spacing) {
                difficultyCard(title: "Easy", solved: stats.easySolved, total: stats.easyTotal, color: .green)
                difficultyCard(title: "Medium", solved: stats.mediumSolved, total: stats.mediumTotal, color: .orange)
                difficultyCard(title: "Hard", solved: stats.hardSolved, total: stats.hardTotal, color: .red)
            }
        }
        .modifier(AppTheme.shared.sectionStyle(in: colorScheme))
        .modifier(AppTheme.shared.cardStyle(in: colorScheme))
    }
    
    private func difficultyCard(title: String, solved: Int, total: Int, color: Color) -> some View {
        let percentage = total > 0 ? Double(solved) / Double(total) : 0
        
        return VStack(alignment: .leading, spacing: UIConstants.spacingSmall) {
            Text(title)
                .font(UIConstants.subheadlineFont)
                .foregroundColor(color)
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(color.opacity(0.2))
                    .frame(height: 6)
                    .cornerRadius(3)
                
                Rectangle()
                    .fill(color)
                    .frame(width: max(CGFloat(percentage) * 100, 0), height: 6)
                    .cornerRadius(3)
            }
            
            Text("\(solved) / \(total)")
                .font(UIConstants.captionFont)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
} 
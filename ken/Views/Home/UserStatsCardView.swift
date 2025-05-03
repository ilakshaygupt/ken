import SwiftUI

struct UserStatsCardView: View {
    let stats: UserStats
    @Environment(\.colorScheme) private var colorScheme
    
    private var solvedPercentage: Double {
        stats.totalProblems > 0 ? Double(stats.totalSolved) / Double(stats.totalProblems) : 0
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("LeetCode Progress")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let ranking = stats.ranking {
                    Text("Rank: \(ranking)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.yellow.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Total Problems Solved")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(stats.totalSolved) / \(stats.totalProblems)")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: geometry.size.width, height: 8)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing))
                            .frame(width: geometry.size.width * CGFloat(solvedPercentage), height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
            }
            
            // Difficulty breakdown
            HStack(spacing: 16) {
                difficultyCard(title: "Easy", solved: stats.easySolved, total: stats.easyTotal, color: .green)
                difficultyCard(title: "Medium", solved: stats.mediumSolved, total: stats.mediumTotal, color: .orange)
                difficultyCard(title: "Hard", solved: stats.hardSolved, total: stats.hardTotal, color: .red)
            }
        }
        .padding()
        .background(AppTheme.shared.cardBackgroundColor(in: colorScheme))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private func difficultyCard(title: String, solved: Int, total: Int, color: Color) -> some View {
        let percentage = total > 0 ? Double(solved) / Double(total) : 0
        
        return VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
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
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
} 
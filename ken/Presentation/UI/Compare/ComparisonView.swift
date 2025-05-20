//
//  ComparisonView.swift
//  ken
//
//  Created by Lakshay Gupta on 04/05/25.
//

import SwiftUI

struct ComparisonView: View {
    let primaryUsername: String
    let compareUsername: String
    let primaryStats: UserStats
    let compareStats: UserStats
    @ObservedObject var leetCodeVM: LeetCodeViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    private let primaryColor = Color.blue
    private let compareColor = Color.green
    private let neutralColor = Color.gray
    
    var body: some View {
        VStack(spacing: 20) {
            header
            statsComparison
            contributionGraphComparison
            progressComparison
            difficultyBarChart
        }
        .padding()
    }
    
    private var header: some View {
        HStack(spacing: 15) {
            VStack(alignment: .center) {
                Text(primaryUsername)
                    .font(.headline)
                    .foregroundColor(primaryColor)
                    .lineLimit(1)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(primaryColor.opacity(0.1))
                    .cornerRadius(8)
            }
            .frame(maxWidth: .infinity)
            
            Text("VS")
                .font(.headline)
                .foregroundColor(neutralColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            
            VStack(alignment: .center) {
                Text(compareUsername)
                    .font(.headline)
                    .foregroundColor(compareColor)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(AppTheme.shared.cardBackgroundColor(in: colorScheme))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var statsComparison: some View {
        VStack(spacing: 18) {
            Text("Problems Solved")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            comparisonRow(label: "Total", value1: primaryStats.totalSolved, value2: compareStats.totalSolved)
            Divider()
            comparisonRow(label: "Easy", value1: primaryStats.easySolved, value2: compareStats.easySolved)
            Divider()
            comparisonRow(label: "Medium", value1: primaryStats.mediumSolved, value2: compareStats.mediumSolved)
            Divider()
            comparisonRow(label: "Hard", value1: primaryStats.hardSolved, value2: compareStats.hardSolved)
        }
        .padding()
        .background(AppTheme.shared.cardBackgroundColor(in: colorScheme))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func comparisonRow(label: String, value1: Int, value2: Int) -> some View {
        HStack {
            Text(label)
                .frame(width: 70, alignment: .leading)
                .foregroundColor(.primary.opacity(0.8))
            
            Text("\(value1)")
                .foregroundColor(primaryColor)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
            
            if value1 > value2 {
                Image(systemName: "arrow.right")
                    .foregroundColor(primaryColor)
                    .font(.system(size: 14, weight: .bold))
            } else if value2 > value1 {
                Image(systemName: "arrow.right")
                    .foregroundColor(compareColor)
                    .font(.system(size: 14, weight: .bold))
            } else {
                Image(systemName: "equal")
                    .foregroundColor(neutralColor)
                    .font(.system(size: 14, weight: .bold))
            }
            
            Text("\(value2)")
                .foregroundColor(compareColor)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
        }
    }
    
    private var contributionGraphComparison: some View {
        VStack(spacing: 16) {
            Text("Contribution Activity")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                contributionSection(username: primaryUsername, color: primaryColor)
                
                Divider()
                    .padding(.vertical, 4)
                
                contributionSection(username: compareUsername, color: compareColor)
            }
        }
        .padding()
        .background(AppTheme.shared.cardBackgroundColor(in: colorScheme))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func contributionSection(username: String, color: Color) -> some View {
        let calendar = leetCodeVM.userCalendars[username]
        let contributions = calendar?.contributions ?? []
        
        return VStack(alignment: .leading, spacing: 8) {
            VStack {
                Text(username)
                    .fontWeight(.medium)
                    .foregroundColor(color)
                
                if let calendar = calendar {
                    Spacer()
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .center, spacing: 0) {
                            Text("\(calendar.streak)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(color)
                            Text("streak")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .center, spacing: 0) {
                            Text("\(calendar.totalActiveDays)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(color)
                            Text("active days")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            if contributions.isEmpty {
                Text("No contribution data available")
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .frame(height: 100)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(color.opacity(0.05))
                    )
            } else {
                ContributionGridView(
                    contributions: contributions,
                    hoveredContribution: .constant(nil),
                    monthsToShow: 11
                )
                .environment(\.contributionColorScheme, color == primaryColor ? .blue : .green)
                .padding(.vertical, 4)
            }
        }
    }
    
    private var progressComparison: some View {
        VStack(spacing: 16) {
            Text("Progress Comparison")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 30) {
                // Primary user progress
                VStack(spacing: 8) {
                    MultiArcProgressView(
                        easyProgress: Double(primaryStats.easySolved) / Double(primaryStats.easyTotal),
                        mediumProgress: Double(primaryStats.mediumSolved) / Double(primaryStats.mediumTotal),
                        hardProgress: Double(primaryStats.hardSolved) / Double(primaryStats.hardTotal),
                        lineWidth: 12,
                        totalQuestions: primaryStats.totalProblems,
                        solvedQuestion: primaryStats.totalSolved
                    )
                    .frame(width: 120, height: 120)
                    
                    Text(primaryUsername)
                        .font(.caption)
                        .foregroundColor(primaryColor)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: 120)
                }
                Divider()
                
                // Compare user progress
                VStack(spacing: 8) {
                    MultiArcProgressView(
                        easyProgress: Double(compareStats.easySolved) / Double(compareStats.easyTotal),
                        mediumProgress: Double(compareStats.mediumSolved) / Double(compareStats.mediumTotal),
                        hardProgress: Double(compareStats.hardSolved) / Double(compareStats.hardTotal),
                        lineWidth: 12,
                        totalQuestions: compareStats.totalProblems,
                        solvedQuestion: compareStats.totalSolved
                    )
                    .frame(width: 120, height: 120)
                    
                    Text(compareUsername)
                        .font(.caption)
                        .foregroundColor(compareColor)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: 120)
                }
            }
        }
        .padding()
        .background(AppTheme.shared.cardBackgroundColor(in: colorScheme))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
    
    private var difficultyBarChart: some View {
        VStack(spacing: 16) {
            Text("Problem Difficulty Breakdown")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 20) {
                // Easy problems
                difficultySection(
                    label: "Easy",
                    value1: primaryStats.easySolved,
                    value2: compareStats.easySolved,
                    total1: primaryStats.easyTotal,
                    total2: compareStats.easyTotal,
                    color: Color(hex: "1cbbba")
                )
                
                // Medium problems
                difficultySection(
                    label: "Medium",
                    value1: primaryStats.mediumSolved,
                    value2: compareStats.mediumSolved,
                    total1: primaryStats.mediumTotal,
                    total2: compareStats.mediumTotal,
                    color: Color.yellow
                )
                
                // Hard problems
                difficultySection(
                    label: "Hard",
                    value1: primaryStats.hardSolved,
                    value2: compareStats.hardSolved,
                    total1: primaryStats.hardTotal,
                    total2: compareStats.hardTotal,
                    color: Color.red
                )
            }
            
            // Legend
            HStack(spacing: 20) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(primaryColor)
                        .frame(width: 8, height: 8)
                    Text(primaryUsername)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(compareColor)
                        .frame(width: 8, height: 8)
                    Text(compareUsername)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .background(AppTheme.shared.cardBackgroundColor(in: colorScheme))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
    
    private func difficultySection(
        label: String,
        value1: Int,
        value2: Int,
        total1: Int,
        total2: Int,
        color: Color
    ) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            HStack(spacing: 12) {
                // Primary user progress
                VStack(alignment: .leading, spacing: 4) {
                    ProgressView(value: Double(value1), total: Double(total1))
                        .progressViewStyle(LinearProgressViewStyle(tint: color))
                        .frame(height: 8)
                    
                    Text("\(value1)/\(total1)")
                        .font(.caption)
                        .foregroundColor(color)
                }
                
                // Compare user progress
                VStack(alignment: .leading, spacing: 4) {
                    ProgressView(value: Double(value2), total: Double(total2))
                        .progressViewStyle(LinearProgressViewStyle(tint: color))
                        .frame(height: 8)
                    
                    Text("\(value2)/\(total2)")
                        .font(.caption)
                        .foregroundColor(color)
                }
            }
        }
    }
} 

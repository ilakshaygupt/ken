//
//  StatsWidgetEntryView.swift
//  ken
//
//  Created by Lakshay Gupta on 25/04/25.
//

import SwiftUI

struct StatsWidgetEntryView: View {
    var entry: StatsWidgetEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        if family == .systemSmall {

            VStack {
                HStack(spacing: 5) {
                    Image("leetcode")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)

                    Text(entry.username)
                        .font(.system(size: 12))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
               
                MultiArcProgressView(
                    easyProgress: Double(entry.stats!.easySolved) / 873,
                    mediumProgress: Double(entry.stats!.mediumSolved) / 1829,
                    hardProgress: Double(entry.stats!.hardSolved) / 824,
                    lineWidth: 10,
                    totalQuestions: entry.stats!.totalProblems,
                    solvedQuestion: entry.stats!.totalSolved
                )
                .frame(width: 100, height: 100)
                
                Spacer(minLength: 0)
            }
            .padding()
        } else {
            if let stats = entry.stats {
                GeometryReader { geometry in
                    VStack {
                        HStack(alignment: .center, spacing: 24) {
                            MultiArcProgressView(
                                easyProgress: Double(entry.stats!.easySolved) / 873,
                                mediumProgress: Double(entry.stats!.mediumSolved) / 1829,
                                hardProgress: Double(entry.stats!.hardSolved) / 824,
                                lineWidth: 10,
                                totalQuestions: entry.stats!.totalProblems,
                                solvedQuestion: entry.stats!.totalSolved
                            )
                            .frame(width: 110, height: 110)
                            
                            VStack(spacing: 8) {
                                HStack {
                                    Image("leetcode")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                    
                                    Text(entry.username)
                                        .font(.system(size: 14))
                                        .foregroundColor(.primary)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(nil)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    DifficultyStatView(
                                        label: "Easy",
                                        solved: entry.stats!.easySolved,
                                        total: entry.stats!.easyTotal,
                                        color: .green
                                    )
                                    DifficultyStatView(
                                        label: "Med.",
                                        solved: entry.stats!.mediumSolved,
                                        total: entry.stats!.mediumTotal,
                                        color: .yellow
                                    )
                                    DifficultyStatView(
                                        label: "Hard",
                                        solved: entry.stats!.hardSolved,
                                        total: entry.stats!.hardTotal,
                                        color: .red
                                    )
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .frame(maxHeight: .infinity)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
                .padding()
                
            } else {
                Text("No data available")
                    .foregroundColor(.secondary)
            }
        }
    }
}

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
            VStack(alignment:.center,spacing: 8){
                HStack {
                    Image("leetcode")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text(entry.username)
                        .font(.system(.caption,design: .monospaced).bold())
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0))
                
                HStack(alignment: .center,spacing: 24) {
                    MultiArcProgressView(
                        easyProgress: Double(entry.stats!.easySolved) / 873,
                        mediumProgress: Double(entry.stats!.mediumSolved) / 1829,
                        hardProgress: Double(entry.stats!.hardSolved) / 824,
                        lineWidth: 10,
                        totalQuestions: entry.stats!.totalProblems,
                        solvedQuestion: entry.stats!.totalSolved
                    )
                    .frame(width: 96, height: 96)
                    VStack(alignment: .leading ) {
                        
                        
                        Spacer()
                        DifficultyStatView(
                            label: "Easy",
                            solved: entry.stats!.easySolved,
                            total: entry.stats!.easyTotal,
                            color: Color(hex: "1cbbba")
                        )
                        Spacer()
                        DifficultyStatView(
                            label: "Med",
                            solved: entry.stats!.mediumSolved,
                            total: entry.stats!.mediumTotal,
                            color: .yellow
                        )
                        Spacer()
                        DifficultyStatView(
                            label: "Hard",
                            solved: entry.stats!.hardSolved,
                            total: entry.stats!.hardTotal,
                            color: .red
                        )
                        Spacer()
                    }
                }
            }
                .padding(EdgeInsets(top: 4, leading: 20, bottom: 0, trailing: 20))
                    }
    }
}

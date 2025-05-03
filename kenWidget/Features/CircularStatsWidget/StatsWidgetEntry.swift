//
//  StatsWidgetEntry.swift
//  ken
//
//  Created by Lakshay Gupta on 25/04/25.
//

import WidgetKit
import SwiftUI

struct StatsWidgetEntry: TimelineEntry {
    let date: Date
    let username: String
    let stats: UserStats?
    
    static let placeholder: StatsWidgetEntry = {
        StatsWidgetEntry(
            date: Date(),
            username: "demolisherguts",
            stats: UserStats(
                totalSolved: 3000,
                easySolved: 97,
                mediumSolved: 182,
                hardSolved: 21,
                easyTotal: 873,
                mediumTotal: 1829,
                hardTotal: 824,
                totalProblems: 300,
                ranking: 3000
            )
        )
    }()
}

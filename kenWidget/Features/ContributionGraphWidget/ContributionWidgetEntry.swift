//
//  ContributionWidgetEntry.swift
//  ken
//
//  Created by Lakshay Gupta on 25/04/25.
//

import WidgetKit
import SwiftUI
import Combine


struct ContributionWidgetEntry: TimelineEntry {
    let date: Date
    let username: String
    let contributions: [LeetCode.UserCalendar.DailyContribution]
    
    static let placeholder: ContributionWidgetEntry = {
        ContributionWidgetEntry(date: Date(), username: "NO USER", contributions: [])
    }()
}

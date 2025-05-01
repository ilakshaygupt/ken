//
//  UserCalendar.swift
//  ken
//
//  Created by Lakshay Gupta on 30/04/25.
//

import Foundation

struct UserCalendar {
    let activeYears: [Int]
    let streak: Int
    let totalActiveDays: Int
    let submissionCalendar: String
    let dccBadges: [Badge]
    
    var contributions: [DailyContribution] {
        DailyContribution.parse(from: submissionCalendar)
    }
}

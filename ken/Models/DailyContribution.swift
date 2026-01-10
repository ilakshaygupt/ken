//
//  DailyContribution.swift
//  ken
//
//  Created by Lakshay Gupta on 30/04/25.
//
import Foundation


struct DailyContribution {
    let date: Date
    let count: Int
    
    static func parse(from calendar: String) -> [DailyContribution] {
        guard !calendar.isEmpty,
              let data = calendar.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Int] else {
            return []
        }
        
        // Pre-allocate capacity for better performance with large datasets
        var contributions: [DailyContribution] = []
        contributions.reserveCapacity(json.count)
        
        for (dateString, count) in json {
            guard let timestampDouble = Double(dateString) else {
                continue
            }
            let date = Date(timeIntervalSince1970: timestampDouble)
            contributions.append(DailyContribution(date: date, count: count))
        }
        
        return contributions
    }
}



//
//  DailyContribution.swift
//  ken
//
//  Created by Lakshay Gupta on 30/04/25.
//
import Foundation


public struct DailyContribution {
    public let date: Date
    public let count: Int
    
    public static func parse(from calendar: String) -> [DailyContribution] {
        guard let data = calendar.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Int] else {
            return []
        }
        
        return json.compactMap { dateString, count in
            guard let timestampDouble = Double(dateString) else {
                return nil
            }
            let date = Date(timeIntervalSince1970: timestampDouble)
            return DailyContribution(date: date, count: count)
        }
    }
}

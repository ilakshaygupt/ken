//
//  LeetCode.swift
//  ken
//
//  Created by Lakshay Gupta on 30/04/25.
//

import Combine
import SwiftUI


public enum LeetCode {
    public static func getUserStats(for username: String, queue: DispatchQueue = .main) -> Future<UserStats, Error> {
        return LeetCodeAPIClient.getUserStats(for: username, queue: queue)
    }
    
     static func getUserCalendar(for username: String, queue: DispatchQueue = .main) -> Future<UserCalendar, Error> {
        return LeetCodeAPIClient.getUserCalendar(for: username, queue: queue)
    }
}

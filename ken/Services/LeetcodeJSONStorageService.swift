//
//  LeetCodeJSONStorageService.swift
//  ken
//
//  Created by Lakshay Gupta on 24/04/25.
//

import Foundation

class LeetCodeJSONStorageService {
    // Keys for UserDefaults
    private let statsResponseKey = "leetcode_stats_json_responses"
    private let calendarResponseKey = "leetcode_calendar_json_responses"
    private let lastFetchedKey = "leetcode_last_fetched_time"
    private let profileResponseKey = "leetcode_profile_json_responses"
    
    private let userDefaults: UserDefaults
    
    init() {
        self.userDefaults = UserDefaults(suiteName: AppGroup)!
    }
    
    // MARK: - Stats JSON Storage
    
    func saveStatsJSONResponse(_ jsonData: Data, forUsername username: String) {
        var responses = getStatsJSONResponses()
        responses[username] = jsonData.base64EncodedString()
        userDefaults.set(responses, forKey: statsResponseKey)
        userDefaults.synchronize()
        updateLastFetchedTime(forUsername: username)
    }
    
    func getStatsJSONResponses() -> [String: String] {
        return userDefaults.dictionary(forKey: statsResponseKey) as? [String: String] ?? [:]
    }
    
    func getStatsJSONResponse(forUsername username: String) -> Data? {
        let responses = getStatsJSONResponses()
        guard let base64String = responses[username] else { return nil }
        return Data(base64Encoded: base64String)
    }
    
    // MARK: - Calendar JSON Storage
    
    func saveCalendarJSONResponse(_ jsonData: Data, forUsername username: String) {
        var responses = getCalendarJSONResponses()
        responses[username] = jsonData.base64EncodedString()
        userDefaults.set(responses, forKey: calendarResponseKey)
        userDefaults.synchronize()
        updateLastFetchedTime(forUsername: username)
    }
    
    func getCalendarJSONResponses() -> [String: String] {
        return userDefaults.dictionary(forKey: calendarResponseKey) as? [String: String] ?? [:]
    }
    
    func getCalendarJSONResponse(forUsername username: String) -> Data? {
        let responses = getCalendarJSONResponses()
        guard let base64String = responses[username] else { return nil }
        return Data(base64Encoded: base64String)
    }
    
    // MARK: - Last Fetched Time
    
    private func lastFetchedTimes() -> [String: Date] {
        guard let timesDict = userDefaults.dictionary(forKey: lastFetchedKey) as? [String: Double] else {
            return [:]
        }
        
        return Dictionary(uniqueKeysWithValues: timesDict.map { (key, value) in
            (key, Date(timeIntervalSince1970: value))
        })
    }
    
    func getLastFetchedTime(forUsername username: String) -> Date? {
        return lastFetchedTimes()[username]
    }
    
    private func updateLastFetchedTime(forUsername username: String) {
        var times = lastFetchedTimes()
        times[username] = Date()
        
        let timeDict = Dictionary(uniqueKeysWithValues: times.map { (key, date) in
            (key, date.timeIntervalSince1970)
        })
        
        userDefaults.set(timeDict, forKey: lastFetchedKey)
        userDefaults.synchronize()
    }
    
    func needsRefresh(forUsername username: String) -> Bool {
        guard let lastFetched = getLastFetchedTime(forUsername: username) else {
            return true
        }
        
        // Refresh if data is older than 1 hour
        let oneHour: TimeInterval = 3600
        return Date().timeIntervalSince(lastFetched) > oneHour
    }
    
    // MARK: - Profile JSON Storage
    
    func saveProfileJSONResponse(_ jsonData: Data, forUsername username: String) {
        var responses = getProfileJSONResponses()
        responses[username] = jsonData.base64EncodedString()
        userDefaults.set(responses, forKey: profileResponseKey)
        userDefaults.synchronize()
        updateLastFetchedTime(forUsername: username)
    }
    
    func getProfileJSONResponses() -> [String: String] {
        return userDefaults.dictionary(forKey: profileResponseKey) as? [String: String] ?? [:]
    }
    
    func getProfileJSONResponse(forUsername username: String) -> Data? {
        let responses = getProfileJSONResponses()
        guard let base64String = responses[username] else { return nil }
        return Data(base64Encoded: base64String)
    }
    
}

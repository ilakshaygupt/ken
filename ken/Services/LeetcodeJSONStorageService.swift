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
    
    // MARK: - Data parsing helpers
    
    func parseUserStats(from jsonData: Data?) -> LeetCode.UserStats? {
        guard let jsonData = jsonData else { return nil }
        
        do {
            let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
            guard let data = json?["data"] as? [String: Any],
                  let matchedUser = data["matchedUser"] as? [String: Any],
                  let submitStats = matchedUser["submitStats"] as? [String: Any],
                  let acSubmissionNum = submitStats["acSubmissionNum"] as? [[String: Any]],
                  let profile = matchedUser["profile"] as? [String: Any] else {
                return nil
            }
            
            var easySolved = 0
            var mediumSolved = 0
            var hardSolved = 0
            
            for submission in acSubmissionNum {
                if let difficulty = submission["difficulty"] as? String,
                   let count = submission["count"] as? Int {
                    switch difficulty {
                    case "Easy": easySolved = count
                    case "Medium": mediumSolved = count
                    case "Hard": hardSolved = count
                    default: break
                    }
                }
            }
            
            let totalSolved = easySolved + mediumSolved + hardSolved
            let ranking = (profile["ranking"] as? Int) ?? 0
            
            return LeetCode.UserStats(
                totalSolved: totalSolved,
                easySolved: easySolved,
                mediumSolved: mediumSolved,
                hardSolved: hardSolved,
                acceptanceRate: 0.0,
                ranking: ranking
            )
        } catch {
            print("Error parsing stats JSON: \(error)")
            return nil
        }
    }
    
    func parseUserCalendar(from jsonData: Data?) -> LeetCode.UserCalendar? {
        guard let jsonData = jsonData else { return nil }
        
        do {
            let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
            guard let data = json?["data"] as? [String: Any],
                  let matchedUser = data["matchedUser"] as? [String: Any],
                  let calendar = matchedUser["userCalendar"] as? [String: Any] else {
                return nil
            }
            
            let activeYears = calendar["activeYears"] as? [Int] ?? []
            let streak = calendar["streak"] as? Int ?? 0
            let totalActiveDays = calendar["totalActiveDays"] as? Int ?? 0
            let submissionCalendar = calendar["submissionCalendar"] as? String ?? "{}"
            let dccBadgesData = calendar["dccBadges"] as? [[String: Any]] ?? []
            
            let dccBadges = dccBadgesData.compactMap { badgeData -> LeetCode.UserCalendar.Badge? in
                guard let timestamp = badgeData["timestamp"] as? Int,
                      let badge = badgeData["badge"] as? [String: Any],
                      let name = badge["name"] as? String,
                      let icon = badge["icon"] as? String else {
                    return nil
                }
                return LeetCode.UserCalendar.Badge(name: name, icon: icon, timestamp: timestamp)
            }
            
            return LeetCode.UserCalendar(
                activeYears: activeYears,
                streak: streak,
                totalActiveDays: totalActiveDays,
                submissionCalendar: submissionCalendar,
                dccBadges: dccBadges
            )
        } catch {
            print("Error parsing calendar JSON: \(error)")
            return nil
        }
    }
}
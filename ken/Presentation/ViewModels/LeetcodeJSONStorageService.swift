//
//  LeetCodeJSONStorageService.swift
//  ken
//
//  Created by Lakshay Gupta on 24/04/25.
//

import Foundation

class LeetCodeJSONStorageService {
    private let userDefaults: UserDefaults?
    
    init() {
        self.userDefaults = UserDefaults(suiteName: AppGroup)
    }
    
    // MARK: - Stats JSON Storage
    
    func saveStatsJSONResponse(_ jsonData: Data, forUsername username: String) {
        guard let userDefaults = userDefaults else { return }
        var responses = getStatsJSONResponses()
        responses[username] = jsonData.base64EncodedString()
        userDefaults.set(responses, forKey: UserDefaultsKeys.leetcodeStatsJSONResponses)
        updateLastFetchedTime(forUsername: username)
    }
    
    func getStatsJSONResponses() -> [String: String] {
        guard let userDefaults = userDefaults else { return [:] }
        return userDefaults.dictionary(forKey: UserDefaultsKeys.leetcodeStatsJSONResponses) as? [String: String] ?? [:]
    }
    
    func getStatsJSONResponse(forUsername username: String) -> Data? {
        let responses = getStatsJSONResponses()
        guard let base64String = responses[username] else { return nil }
        return Data(base64Encoded: base64String)
    }
    
    // MARK: - Calendar JSON Storage
    
    func saveCalendarJSONResponse(_ jsonData: Data, forUsername username: String) {
        guard let userDefaults = userDefaults else { return }
        var responses = getCalendarJSONResponses()
        responses[username] = jsonData.base64EncodedString()
        userDefaults.set(responses, forKey: UserDefaultsKeys.leetcodeCalendarJSONResponses)
        updateLastFetchedTime(forUsername: username)
    }
    
    func getCalendarJSONResponses() -> [String: String] {
        guard let userDefaults = userDefaults else { return [:] }
        return userDefaults.dictionary(forKey: UserDefaultsKeys.leetcodeCalendarJSONResponses) as? [String: String] ?? [:]
    }
    
    func getCalendarJSONResponse(forUsername username: String) -> Data? {
        let responses = getCalendarJSONResponses()
        guard let base64String = responses[username] else { return nil }
        return Data(base64Encoded: base64String)
    }
    
    // MARK: - Last Fetched Time
    
    private func lastFetchedTimes() -> [String: Date] {
        guard let userDefaults = userDefaults,
              let timesDict = userDefaults.dictionary(forKey: UserDefaultsKeys.leetcodeLastFetchedTime) as? [String: Double] else {
            return [:]
        }
        
        return Dictionary(uniqueKeysWithValues: timesDict.map { (key, value) in
            (key, Date(timeIntervalSince1970: value))
        })
    }
    
    func getLastFetchedTime(forUsername username: String) -> Date? {
        lastFetchedTimes()[username]
    }
    
    private func updateLastFetchedTime(forUsername username: String) {
        guard let userDefaults = userDefaults else { return }
        var times = lastFetchedTimes()
        times[username] = Date()
        
        let timeDict = Dictionary(uniqueKeysWithValues: times.map { (key, date) in
            (key, date.timeIntervalSince1970)
        })
        
        userDefaults.set(timeDict, forKey: UserDefaultsKeys.leetcodeLastFetchedTime)
    }
    
    func needsRefresh(forUsername username: String) -> Bool {
        guard let lastFetched = getLastFetchedTime(forUsername: username) else {
            return true
        }
        let oneHour: TimeInterval = 3600
        return Date().timeIntervalSince(lastFetched) > oneHour
    }
    
    // MARK: - Profile JSON Storage
    
    func saveProfileJSONResponse(_ jsonData: Data, forUsername username: String) {
        guard let userDefaults = userDefaults else { return }
        var responses = getProfileJSONResponses()
        responses[username] = jsonData.base64EncodedString()
        userDefaults.set(responses, forKey: UserDefaultsKeys.leetcodeProfileJSONResponses)
        updateLastFetchedTime(forUsername: username)
    }
    
    func getProfileJSONResponses() -> [String: String] {
        guard let userDefaults = userDefaults else { return [:] }
        return userDefaults.dictionary(forKey: UserDefaultsKeys.leetcodeProfileJSONResponses) as? [String: String] ?? [:]
    }
    
    func getProfileJSONResponse(forUsername username: String) -> Data? {
        let responses = getProfileJSONResponses()
        guard let base64String = responses[username] else { return nil }
        return Data(base64Encoded: base64String)
    }
    
}

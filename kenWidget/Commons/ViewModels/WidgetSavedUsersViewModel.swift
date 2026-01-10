//
//  WidgetSavedUsersViewModel.swift
//  ken
//
//  Created by Lakshay Gupta on 25/04/25.
//

import WidgetKit
import Combine

class WidgetSavedUsersViewModel: ObservableObject {
    @Published var savedUsernames: [String] = []
    private let storageService = LeetCodeJSONStorageService()
    
    private var userDefaults: UserDefaults? {
        UserDefaults(suiteName: AppGroup)
    }
    
    init() {
        loadSavedUsernames()
    }
    
    func loadSavedUsernames() {
        guard let userDefaults = userDefaults else { return }
        if let usernames = userDefaults.stringArray(forKey: UserDefaultsKeys.leetcodeUsernames) {
            savedUsernames = usernames
        }
    }
    
    func getUserCalendar(for username: String) -> UserCalendar? {
        guard let calendarData = storageService.getCalendarJSONResponse(forUsername: username) else {
            return nil
        }
        return LeetCodeJSONParser.parseUserCalendar(from: calendarData)
    }
    
    func getUserStats(for username: String) -> UserStats? {
        guard let statsData = storageService.getStatsJSONResponse(forUsername: username) else {
            return nil
        }
        return LeetCodeJSONParser.parseUserStats(from: statsData)
    }
}

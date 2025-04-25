//
//  WidgetSavedUsersViewModel.swift
//  ken
//
//  Created by Lakshay Gupta on 25/04/25.
//



import WidgetKit
import AppIntents
import Intents
import Combine

class WidgetSavedUsersViewModel: ObservableObject {
    @Published var savedUsernames: [String] = []
    private let userDefaultsKey = "leetcode_usernames"
    private let storageService = LeetCodeJSONStorageService()
    
    init() {
        loadSavedUsernames()
    }
    
    func loadSavedUsernames() {
        if let usernames = UserDefaults(suiteName: AppGroup)!.stringArray(forKey: userDefaultsKey) {
            savedUsernames = usernames
        }
    }
    
    func getUserCalendar(for username: String) -> LeetCode.UserCalendar? {
        if let calendarData = storageService.getCalendarJSONResponse(forUsername: username) {
            return storageService.parseUserCalendar(from: calendarData)
        }
        return nil
    }
    
    func getUserStats(for username: String) -> LeetCode.UserStats? {
        if let statsData = storageService.getStatsJSONResponse(forUsername: username) {
            return storageService.parseUserStats(from: statsData)
        }
        return nil
    }
}
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
    
    func getUserCalendar(for username: String) -> UserCalendar? {
        if let calendarData = storageService.getCalendarJSONResponse(forUsername: username) {
            return LeetCodeJSONParser.parseUserCalendar(from: calendarData)
        }
        return nil
    }
    
    func getUserStats(for username: String) -> UserStats? {
        if let statsData = storageService.getStatsJSONResponse(forUsername: username) {
            return LeetCodeJSONParser.parseUserStats(from: statsData)
        }
        return nil
    }
}

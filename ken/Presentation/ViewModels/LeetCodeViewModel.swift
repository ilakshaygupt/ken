//
//  LeetCodeViewModel.swift
//  ken
//
//  Created by Lakshay Gupta on 31/01/25.
//

import SwiftUI
import Combine
import WidgetKit

class LeetCodeViewModel: ObservableObject {
    @Published var currentUsername: String = ""
    @Published var userProfiles: [String: UserProfile] = [:]
    @Published var userStats: [String: UserStats] = [:]
    @Published var userCalendars: [String: UserCalendar] = [:]
    @Published var isLoading = false
    @Published var isFetchingFreshData = false
    @Published var error: Error?
    
    private var cancellables = Set<AnyCancellable>()
    private let storageService = LeetCodeJSONStorageService()
    
    init() {
        loadCachedData()
    }
    
    private func loadCachedData() {
        guard let usernames = UserDefaults(suiteName: AppGroup)?.stringArray(forKey: "leetcode_usernames") else {
            return
        }
        
        for username in usernames {
            loadCachedDataForUser(username)
        }
    }
    
    private func loadCachedDataForUser(_ username: String) {
        // Load stats from cache
        if let statsData = storageService.getStatsJSONResponse(forUsername: username),
           let stats = LeetCodeJSONParser.parseUserStats(from: statsData) {
            Task { @MainActor in
                userStats[username] = stats
            }
        }
        
        if let calendarData = storageService.getCalendarJSONResponse(forUsername: username),
           let calendar = LeetCodeJSONParser.parseUserCalendar(from: calendarData) {
            Task { @MainActor in
                userCalendars[username] = calendar
            }
        }
        
        if let profileData = storageService.getProfileJSONResponse(forUsername: username),
           let profile = LeetCodeJSONParser.parseUserProfile(from: profileData) {
            Task { @MainActor in
                userProfiles[username] = profile
            }
        }
    }
    
    func fetchData(for username: String, forceRefresh: Bool = false) async -> Bool {
        await MainActor.run {
            error = nil
        }
        
        
        
        let hasCachedStats = userStats[username] != nil
        let hasCachedCalendar = userCalendars[username] != nil
        let hasCachedData = hasCachedStats && hasCachedCalendar
        
        let needsRefresh = forceRefresh || storageService.needsRefresh(forUsername: username)
        
        if hasCachedData && !needsRefresh {
            return true
        }
        
        if hasCachedData && needsRefresh {
            await MainActor.run {
                isFetchingFreshData = true
            }
        } else {
            await MainActor.run {
                isLoading = true
            }
        }
        
        return await fetchFreshData(for: username)
    }

    
    private func fetchFreshData(for username: String) async -> Bool {
        return await withCheckedContinuation { continuation in
            var operationCancellables = Set<AnyCancellable>()
            
            let statsPublisher = LeetCodeAPIClient.getUserStats(for: username, queue: .global())
            let calendarPublisher = LeetCodeAPIClient.getUserCalendar(for: username, queue: .global())
            
            Publishers.Zip(statsPublisher, calendarPublisher)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] completionStatus in
                        guard let self else { 
                            continuation.resume(returning: false)
                            return 
                        }
                        
                        Task { @MainActor in
                            self.isLoading = false
                            self.isFetchingFreshData = false
                        }
                        
                        switch completionStatus {
                        case .finished:
                            continuation.resume(returning: true)
                        case .failure(let err):
                            Task { @MainActor in
                                self.error = err
                            }
                            continuation.resume(returning: false)
                        }
                    },
                    receiveValue: { [weak self] stats, calendar in
                        guard let self else { return }
                        
                        Task { @MainActor in
                            self.userStats[username] = stats
                            self.userCalendars[username] = calendar
                        }
                        
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                )
                .store(in: &operationCancellables)
            
            self.cancellables.formUnion(operationCancellables)
        }
    }


    
    func fetchUserProfile(for username: String, forceRefresh: Bool = false) async {
        if !forceRefresh,
           let profileData = storageService.getProfileJSONResponse(forUsername: username),
           !storageService.needsRefresh(forUsername: username),
           let profile = LeetCodeJSONParser.parseUserProfile(from: profileData) {
            await MainActor.run {
                self.userProfiles[username] = profile
            }
            return
        }
        
        return await withCheckedContinuation { continuation in
            LeetCodeAPIClient.getUserProfile(for: username, queue: .global())
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            print("Error fetching user profile: \(error)")
                            continuation.resume()
                        }
                    },
                    receiveValue: { [weak self] result in
                        guard let self = self else { return }
                        let (profile, responseData) = result
                        Task { @MainActor in
                            self.userProfiles[username] = profile
                        }
                        self.storageService.saveProfileJSONResponse(responseData, forUsername: username)
                        continuation.resume()
                    }
                )
                .store(in: &cancellables)
        }
    }
    
    func refreshAllUsers() async {
        let usernames = Set(userStats.keys).union(userCalendars.keys)
        
        for username in usernames {
            await fetchData(for: username, forceRefresh: true)
        }
    }
    
    // MARK: - Cache Management
    
    func getCacheInfo(for username: String) -> (hasCache: Bool, lastFetched: Date?, needsRefresh: Bool) {
        let hasStats = storageService.getStatsJSONResponse(forUsername: username) != nil
        let hasCalendar = storageService.getCalendarJSONResponse(forUsername: username) != nil
        let hasProfile = storageService.getProfileJSONResponse(forUsername: username) != nil
        
        return (
            hasCache: hasStats && hasCalendar && hasProfile,
            lastFetched: storageService.getLastFetchedTime(forUsername: username),
            needsRefresh: storageService.needsRefresh(forUsername: username)
        )
    }
    
    func clearCache(for username: String? = nil) {
        if let username = username {
            var statsResponses = storageService.getStatsJSONResponses()
            var calendarResponses = storageService.getCalendarJSONResponses()
            var profileResponses = storageService.getProfileJSONResponses()
            
            statsResponses.removeValue(forKey: username)
            calendarResponses.removeValue(forKey: username)
            profileResponses.removeValue(forKey: username)
            
            UserDefaults(suiteName: AppGroup)?.set(statsResponses, forKey: "leetcode_stats_json_responses")
            UserDefaults(suiteName: AppGroup)?.set(calendarResponses, forKey: "leetcode_calendar_json_responses")
            UserDefaults(suiteName: AppGroup)?.set(profileResponses, forKey: "leetcode_profile_json_responses")
            
            // Clear from memory
            Task { @MainActor in
                userStats.removeValue(forKey: username)
                userCalendars.removeValue(forKey: username)
                userProfiles.removeValue(forKey: username)
            }
        } else {
            // Clear all cache
            UserDefaults(suiteName: AppGroup)?.removeObject(forKey: "leetcode_stats_json_responses")
            UserDefaults(suiteName: AppGroup)?.removeObject(forKey: "leetcode_calendar_json_responses")
            UserDefaults(suiteName: AppGroup)?.removeObject(forKey: "leetcode_profile_json_responses")
            UserDefaults(suiteName: AppGroup)?.removeObject(forKey: "leetcode_last_fetched_time")
            
            // Clear from memory
            Task { @MainActor in
                userStats.removeAll()
                userCalendars.removeAll()
                userProfiles.removeAll()
            }
        }
        
        UserDefaults(suiteName: AppGroup)?.synchronize()
    }
}

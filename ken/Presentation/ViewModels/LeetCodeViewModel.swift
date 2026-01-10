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
        guard let usernames = UserDefaults(suiteName: AppGroup)?.stringArray(forKey: UserDefaultsKeys.leetcodeUsernames) else {
            return
        }
        
        for username in usernames {
            loadCachedDataForUser(username)
        }
    }
    
    private func loadCachedDataForUser(_ username: String) {
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            
            // Load all cached data in parallel
            async let statsTask = Task {
                if let statsData = self.storageService.getStatsJSONResponse(forUsername: username),
                   let stats = LeetCodeJSONParser.parseUserStats(from: statsData) {
                    return (username, stats)
                }
                return nil as (String, UserStats)?
            }
            
            async let calendarTask = Task {
                if let calendarData = self.storageService.getCalendarJSONResponse(forUsername: username),
                   let calendar = LeetCodeJSONParser.parseUserCalendar(from: calendarData) {
                    return (username, calendar)
                }
                return nil as (String, UserCalendar)?
            }
            
            async let profileTask = Task {
                if let profileData = self.storageService.getProfileJSONResponse(forUsername: username),
                   let profile = LeetCodeJSONParser.parseUserProfile(from: profileData) {
                    return (username, profile)
                }
                return nil as (String, UserProfile)?
            }
            
            // Update UI on main thread after all data is loaded
            let (statsResult, calendarResult, profileResult) = await (statsTask.value, calendarTask.value, profileTask.value)
            
            await MainActor.run {
                if let (username, stats) = statsResult {
                    self.userStats[username] = stats
                }
                if let (username, calendar) = calendarResult {
                    self.userCalendars[username] = calendar
                }
                if let (username, profile) = profileResult {
                    self.userProfiles[username] = profile
                }
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
        
        // Check refresh status off main thread
        let needsRefresh = await Task.detached(priority: .userInitiated) {
            forceRefresh || self.storageService.needsRefresh(forUsername: username)
        }.value
        
        if hasCachedData && !needsRefresh {
            return true
        }
        
        await MainActor.run {
            if hasCachedData && needsRefresh {
                isFetchingFreshData = true
            } else {
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
                        
                        // Reload widgets off main thread
                        Task.detached(priority: .utility) {
                            WidgetCenter.shared.reloadAllTimelines()
                        }
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
                    receiveCompletion: { [weak self] completion in
                        if case .failure(let error) = completion {
                            Task { @MainActor in
                                self?.error = error
                            }
                            continuation.resume()
                        }
                    },
                    receiveValue: { [weak self] result in
                        guard let self = self else { return }
                        let (profile, responseData) = result
                        Task { @MainActor in
                            self.userProfiles[username] = profile
                        }
                        // Avatar caching: download only on force refresh or URL change
                        if let avatarURL = profile.userAvatar, !avatarURL.isEmpty {
                            let cache = AvatarImageCacheService.shared
                            let shouldDownload = cache.needsDownload(for: username, remoteURLString: avatarURL, force: forceRefresh)
                            if shouldDownload {
                                cache.downloadAndCacheAvatar(for: username, remoteURLString: avatarURL)
                            }
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
    
    // MARK: - Preload All Users Data
    
    func preloadAllUsersData(usernames: [String], forceRefresh: Bool = false) async {
        await withTaskGroup(of: Void.self) { group in
            for username in usernames {
                group.addTask { [weak self] in
                    guard let self = self else { return }
                    // Fetch stats and calendar in parallel
                    async let dataFetch = self.fetchData(for: username, forceRefresh: forceRefresh)
                    async let profileFetch = self.fetchUserProfile(for: username, forceRefresh: forceRefresh)
                    
                    // Wait for both to complete
                    let _ = await (dataFetch, profileFetch)
                }
            }
        }
    }
    
    // MARK: - Cache Management
    
    func getCacheInfo(for username: String) async -> (hasCache: Bool, lastFetched: Date?, needsRefresh: Bool) {
        return await Task.detached(priority: .userInitiated) {
            let hasStats = self.storageService.getStatsJSONResponse(forUsername: username) != nil
            let hasCalendar = self.storageService.getCalendarJSONResponse(forUsername: username) != nil
            let hasProfile = self.storageService.getProfileJSONResponse(forUsername: username) != nil
            
            return (
                hasCache: hasStats && hasCalendar && hasProfile,
                lastFetched: self.storageService.getLastFetchedTime(forUsername: username),
                needsRefresh: self.storageService.needsRefresh(forUsername: username)
            )
        }.value
    }
    
    func clearCache(for username: String? = nil) {
        if let username = username {
            var statsResponses = storageService.getStatsJSONResponses()
            var calendarResponses = storageService.getCalendarJSONResponses()
            var profileResponses = storageService.getProfileJSONResponses()
            
            statsResponses.removeValue(forKey: username)
            calendarResponses.removeValue(forKey: username)
            profileResponses.removeValue(forKey: username)
            
            UserDefaults(suiteName: AppGroup)?.set(statsResponses, forKey: UserDefaultsKeys.leetcodeStatsJSONResponses)
            UserDefaults(suiteName: AppGroup)?.set(calendarResponses, forKey: UserDefaultsKeys.leetcodeCalendarJSONResponses)
            UserDefaults(suiteName: AppGroup)?.set(profileResponses, forKey: UserDefaultsKeys.leetcodeProfileJSONResponses)
            
            // Clear from memory
            Task { @MainActor in
                userStats.removeValue(forKey: username)
                userCalendars.removeValue(forKey: username)
                userProfiles.removeValue(forKey: username)
            }
        } else {
            // Clear all cache
            UserDefaults(suiteName: AppGroup)?.removeObject(forKey: UserDefaultsKeys.leetcodeStatsJSONResponses)
            UserDefaults(suiteName: AppGroup)?.removeObject(forKey: UserDefaultsKeys.leetcodeCalendarJSONResponses)
            UserDefaults(suiteName: AppGroup)?.removeObject(forKey: UserDefaultsKeys.leetcodeProfileJSONResponses)
            UserDefaults(suiteName: AppGroup)?.removeObject(forKey: UserDefaultsKeys.leetcodeLastFetchedTime)
            
            // Clear from memory
            Task { @MainActor in
                userStats.removeAll()
                userCalendars.removeAll()
                userProfiles.removeAll()
            }
        }
        
    }
}

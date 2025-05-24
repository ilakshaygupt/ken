//
//  LeetCodeViewModel.swift
//  ken
//
//  Created by Lakshay Gupta on 31/01/25.
//

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
        if let usernames = UserDefaults(suiteName: AppGroup)!.stringArray(forKey: "leetcode_usernames") {
            
            for username in usernames {
                if let statsData = storageService.getStatsJSONResponse(forUsername: username),
                   let stats = LeetCodeJSONParser.parseUserStats(from: statsData) {
                    userStats[username] = stats
                }
                
                if let calendarData = storageService.getCalendarJSONResponse(forUsername: username),
                   let calendar = LeetCodeJSONParser.parseUserCalendar(from: calendarData) {
                    userCalendars[username] = calendar
                }
            }
        }
    }
    
    
    func fetchData(for username: String, forceRefresh: Bool = false) async -> Bool {
        await MainActor.run {
            error = nil
        }
        
        let hasCachedData = userStats[username] != nil && userCalendars[username] != nil
        print("has cached data \(hasCachedData) \(username)")
        
        if hasCachedData && !forceRefresh && !storageService.needsRefresh(forUsername: username) {
            print("hasCachedData: \(hasCachedData) \(username)")
            return true
        }
        
        if hasCachedData && !forceRefresh {
            print("FETCHING FRESH DATA \(username)")
            await MainActor.run { isFetchingFreshData = true }
        } else {
            await MainActor.run { isLoading = true }
        }
        
        print("FETCHING LATEST DATA FOR ALL \(username)")
        return await fetchFreshData(for: username)
    }

    private func fetchFreshData(for username: String) async -> Bool {
        return await withCheckedContinuation { continuation in
            let statsPublisher = LeetCodeAPIClient.getUserStats(for: username, queue: .global())
            let calendarPublisher = LeetCodeAPIClient.getUserCalendar(for: username, queue: .global())
            
            Publishers.Zip(statsPublisher, calendarPublisher)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] completionStatus in
                        guard let self = self else {
                            continuation.resume(returning: false)
                            return
                        }
                        
                        self.isLoading = false
                        self.isFetchingFreshData = false
                        
                        if case .failure(let err) = completionStatus {
                            self.error = err
                            continuation.resume(returning: false)
                        }
                    },
                    receiveValue: { [weak self] stats, calendar in
                        guard let self = self else {
                            continuation.resume(returning: false)
                            return
                        }
                        
                        self.userStats[username] = stats
                        self.userCalendars[username] = calendar
                        
                        WidgetCenter.shared.reloadAllTimelines()
                        continuation.resume(returning: true)
                    }
                )
                .store(in: &cancellables)
        }
    }

    func fetchUserProfile(for username: String) async {
        if let profileData = storageService.getProfileJSONResponse(forUsername: username),
           !storageService.needsRefresh(forUsername: username),
           let profile = LeetCodeJSONParser.parseUserProfile(from: profileData) {
            
            await MainActor.run {
                self.userProfiles[username] = profile
            }
            return
        }
        
        
        await withCheckedContinuation { continuation in
            LeetCodeAPIClient.getUserProfile(for: username, queue: .global())
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        guard let self = self else {
                            continuation.resume()
                            return
                        }
                        if case .failure(let error) = completion {
                            self.error = error
                            print("Error fetching user profile: \(error)")
                        }
                        continuation.resume()
                    },
                    receiveValue: { [weak self] result in
                        guard let self = self else {
                            continuation.resume()
                            return
                        }
                        let (profile, responseData) = result
                        self.userProfiles[username] = profile
                        self.storageService.saveProfileJSONResponse(responseData, forUsername: username)
                        continuation.resume()
                    }
                )
                .store(in: &self.cancellables)
        }
    }
    
    
    func fetchUserProfileSync(for username: String) {
        if let profileData = storageService.getProfileJSONResponse(forUsername: username),
           !storageService.needsRefresh(forUsername: username),
           let profile = LeetCodeJSONParser.parseUserProfile(from: profileData) {
            self.userProfiles[username] = profile
            return
        }
        
        LeetCodeAPIClient.getUserProfile(for: username, queue: .global())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    if case .failure(let error) = completion {
                        self.error = error
                        print("Error fetching user profile: \(error)")
                    }
                },
                receiveValue: { [weak self] result in
                    guard let self = self else { return }
                    let (profile, responseData) = result
                    self.userProfiles[username] = profile
                    self.storageService.saveProfileJSONResponse(responseData, forUsername: username)
                }
            )
            .store(in: &cancellables)
    }
}

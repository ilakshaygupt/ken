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
    
    func fetchData(for username: String, forceRefresh: Bool = false, completion: ((Bool) -> Void)? = nil) {
        
        error = nil

        let hasCachedData = userStats[username] != nil && userCalendars[username] != nil
        
        if hasCachedData && !forceRefresh && !storageService.needsRefresh(forUsername: username) {
            completion?(true)
            return
        }
        
        if hasCachedData && !forceRefresh {
            isFetchingFreshData = true
        } else {
            isLoading = true
        }
        
        fetchFreshData(for: username, completion: completion)
    }
    
    private func fetchFreshData(for username: String, completion: ((Bool) -> Void)? = nil) {

        let statsPublisher = LeetCodeAPIClient.getUserStats(for: username, queue: .global())
        let calendarPublisher = LeetCodeAPIClient.getUserCalendar(for: username, queue: .global())
        
        Publishers.Zip(statsPublisher, calendarPublisher)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completionStatus in
                    self?.isLoading = false
                    self?.isFetchingFreshData = false
                    
                    if case .failure(let err) = completionStatus {
                        self?.error = err
                        completion?(false)
                    } else {
                        completion?(true)
                    }
                },
                receiveValue: { [weak self] stats, calendar in
                    guard let self = self else { return }
                    
                    self.userStats[username] = stats
                    self.userCalendars[username] = calendar
                    
                    WidgetCenter.shared.reloadAllTimelines()
                }
            )
            .store(in: &cancellables)
    }
    
    func fetchUserProfile(for username: String) {
        if let profileData = storageService.getProfileJSONResponse(forUsername: username),
           !storageService.needsRefresh(forUsername: username),
           let profile = LeetCodeJSONParser.parseUserProfile(from: profileData) {
            self.userProfiles[username] = profile
            return
        }
        
        LeetCodeAPIClient.getUserProfile(for: username, queue: .global())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
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
    
    func refreshAllUsers() {
        
        let usernames = Set(userStats.keys).union(userCalendars.keys)
        
        for username in usernames {
            fetchData(for: username, forceRefresh: true)
        }
    }
}

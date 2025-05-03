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
                   let stats = storageService.parseUserStats(from: statsData) {
                    userStats[username] = stats
                }
                
                if let calendarData = storageService.getCalendarJSONResponse(forUsername: username),
                   let calendar = storageService.parseUserCalendar(from: calendarData) {
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
        
        let statsPublisher = createStatsFetchPublisher(for: username)
        
        
        let calendarPublisher = createCalendarFetchPublisher(for: username)
        
        
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
    
    private func createStatsFetchPublisher(for username: String) -> AnyPublisher<UserStats, Error> {
        
        return Future<UserStats, Error> { promise in
            
            let query = """
            query userSessionProgress($username: String!) {
              allQuestionsCount {
                difficulty
                count
              }
              matchedUser(username: $username) {
                submitStats {
                  acSubmissionNum {
                    difficulty
                    count
                    submissions
                  }
                  totalSubmissionNum {
                    difficulty
                    count
                    submissions
                  }
                }
                profile {
                  ranking
                }
              }
            }
            """
            
            let variables = ["username": username]
            
            var request = URLRequest(url: URL(string: "https://leetcode.com/graphql")!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("https://leetcode.com", forHTTPHeaderField: "Referer")
            
            let body = [
                "query": query,
                "variables": variables
            ] as [String : Any]
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let data = data else {
                    promise(.failure(URLError(.badServerResponse)))
                    return
                }
                
                
                self?.storageService.saveStatsJSONResponse(data, forUsername: username)
                
                
                if let stats = self?.storageService.parseUserStats(from: data) {
                    promise(.success(stats))
                } else {
                    promise(.failure(URLError(.cannotParseResponse)))
                }
            }.resume()
        }.eraseToAnyPublisher()
    }
    
    private func createCalendarFetchPublisher(for username: String) -> AnyPublisher<UserCalendar, Error> {
        
        return Future<UserCalendar, Error> { promise in
            
            let query = """
            query userProfileCalendar($username: String!, $year: Int) {
                matchedUser(username: $username) {
                    userCalendar(year: $year) {
                        activeYears
                        streak
                        totalActiveDays
                        dccBadges {
                            timestamp
                            badge {
                                name
                                icon
                            }
                        }
                        submissionCalendar
                    }
                }
            }
            """
            
            let variables = ["username": username]
            
            var request = URLRequest(url: URL(string: "https://leetcode.com/graphql")!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("https://leetcode.com", forHTTPHeaderField: "Referer")
            
            let body = [
                "query": query,
                "variables": variables,
                "operationName": "userProfileCalendar"
            ] as [String : Any]
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let data = data else {
                    promise(.failure(URLError(.badServerResponse)))
                    return
                }
                
                
                self?.storageService.saveCalendarJSONResponse(data, forUsername: username)
                
                
                if let calendar = self?.storageService.parseUserCalendar(from: data) {
                    promise(.success(calendar))
                } else {
                    promise(.failure(URLError(.cannotParseResponse)))
                }
            }.resume()
        }.eraseToAnyPublisher()
    }
    
    func refreshAllUsers() {
        
        let usernames = Set(userStats.keys).union(userCalendars.keys)
        
        
        for username in usernames {
            fetchData(for: username, forceRefresh: true)
        }
    }
}

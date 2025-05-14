//
//  SearchViewModel.swift
//  ken
//
//  Created by Lakshay Gupta on 09/05/25.
//
import Foundation
import Combine
import SwiftUI

class SearchViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var isLoading = false
    @Published var error: Error?
    @Published var userStats: UserStats?
    @Published var userCalendar: UserCalendar?
    @Published var userProfile: UserProfile?
    
    private var cancellables = Set<AnyCancellable>()
    private let queue = DispatchQueue(label: "com.leetcode.search", qos: .userInitiated)


    
    func searchUser() {
        guard !username.isEmpty else { return }
        
        isLoading = true
        error = nil
        userStats = nil
        userCalendar = nil
        userProfile = nil
        
        let group = DispatchGroup()
        var receivedValidData = false
        
        group.enter()
        LeetCode.getUserStats(for: username,queue: queue)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error
                }
                group.leave()
            }, receiveValue: { [weak self] stats in
                self?.userStats = stats
                receivedValidData = true
            })
            .store(in: &cancellables)
        
        group.enter()
        LeetCode.getUserCalendar(for: username,queue: queue)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error
                }
                group.leave()
            }, receiveValue: { [weak self] calendar in
                self?.userCalendar = calendar
                receivedValidData = true
            })
            .store(in: &cancellables)
        
        group.enter()
        LeetCode.getUserProfile(for: username)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error
                    self?.userStats = nil
                    self?.userCalendar = nil
                    self?.userProfile = nil
                }
                group.leave()
            }, receiveValue: { [weak self] (profile, _) in
                self?.userProfile = profile
                receivedValidData = true
            })
            .store(in: &cancellables)
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.isLoading = false
            
            if !receivedValidData && self.error == nil {
                self.error = NSError(
                    domain: "com.leetcode.search",
                    code: 404,
                    userInfo: [NSLocalizedDescriptionKey: "User '\(self.username)' not found or data couldn't be retrieved."]
                )
            }
        }
    }
}


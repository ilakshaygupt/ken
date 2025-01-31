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
    @Published var userStats: [String: LeetCode.UserStats] = [:]
    @Published var userCalendars: [String: LeetCode.UserCalendar] = [:]
    @Published var isLoading = false
    @Published var error: Error?
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchData(for username: String) {
        isLoading = true
        error = nil
        
        Publishers.Zip(
            LeetCode.getUserStats(for: username, queue: .global()),
            LeetCode.getUserCalendar(for: username, queue: .global())
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let err) = completion {
                    self?.error = err
                }
            },
            receiveValue: { [weak self] stats, calendar in
                self?.userStats[username] = stats
                self?.userCalendars[username] = calendar
                
                // Trigger widget refresh
                WidgetCenter.shared.reloadAllTimelines()
            }
        )
        .store(in: &cancellables)
    }
} 

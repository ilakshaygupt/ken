//
//  SavedUsersViewModel.swift
//  ken
//
//  Created by Lakshay Gupta on 31/01/25.
//


import SwiftUI




class SavedUsersViewModel: ObservableObject {
    @Published var savedUsernames: [String] = []
    private let userDefaultsKey = "leetcode_usernames"
    
    init() {
        loadSavedUsernames()
    }
    
    func loadSavedUsernames() {
        if let usernames = UserDefaults(suiteName: AppGroup)!.stringArray(forKey: userDefaultsKey) {
            savedUsernames = usernames
        }
    }
    
    func addUsername(_ username: String) {
        if !savedUsernames.contains(username) {
            savedUsernames.append(username)
            saveToDisk()
        }
    }
    
    func removeUsername(_ username: String) {
        if let index = savedUsernames.firstIndex(of: username) {
            savedUsernames.remove(at: index)
            saveToDisk()
        }
    }
    
    private func saveToDisk() {
        UserDefaults(suiteName: AppGroup)!.set(savedUsernames, forKey: userDefaultsKey)
        UserDefaults(suiteName: AppGroup)!.synchronize()
    }
} 

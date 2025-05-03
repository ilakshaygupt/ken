//
//  SavedUsersViewModel.swift
//  ken
//
//  Created by Lakshay Gupta on 31/01/25.
//


import SwiftUI




class SavedUsersViewModel: ObservableObject {
    @Published var savedUsernames: [String] = []
    @Published var primaryUsername: String?
    
    private let userDefaultsKey = "leetcode_usernames"
    private let primaryUsernameKey = "primary_leetcode_username"
    
    init() {
        loadSavedUsernames()
        loadPrimaryUsername()
    }
    
    func loadSavedUsernames() {
        if let usernames = UserDefaults(suiteName: AppGroup)!.stringArray(forKey: userDefaultsKey) {
            savedUsernames = usernames
        }
    }
    
    func loadPrimaryUsername() {
        primaryUsername = UserDefaults(suiteName: AppGroup)!.string(forKey: primaryUsernameKey)
    }
    
    func hasPrimaryUsername() -> Bool {
        return primaryUsername != nil
    }
    
    func setPrimaryUsername(_ username: String) {
        
        primaryUsername = username
        UserDefaults(suiteName: AppGroup)!.set(username, forKey: primaryUsernameKey)
        
        
        if !savedUsernames.contains(username) {
            savedUsernames.append(username)
            saveToDisk()
        }
    }
    
    func changePrimaryUsername(_ username: String) {
        
        if !savedUsernames.contains(username) {
            return
        }
        
        
        setPrimaryUsername(username)
    }
    
    func addUsername(_ username: String) {
        if !savedUsernames.contains(username) {
            savedUsernames.append(username)
            saveToDisk()
        }
    }
    
    func removeUsername(_ username: String) {
        if username == primaryUsername {
            return
        }
        
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

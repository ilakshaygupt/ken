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
    
    private var userDefaults: UserDefaults? {
        UserDefaults(suiteName: AppGroup)
    }
    
    init() {
        loadSavedUsernames()
        loadPrimaryUsername()
    }
    
    func loadSavedUsernames() {
        guard let userDefaults = userDefaults else { return }
        if let usernames = userDefaults.stringArray(forKey: UserDefaultsKeys.leetcodeUsernames) {
            savedUsernames = usernames
        }
    }
    
    func loadPrimaryUsername() {
        guard let userDefaults = userDefaults else { return }
        primaryUsername = userDefaults.string(forKey: UserDefaultsKeys.primaryLeetcodeUsername)
    }
    
    func hasPrimaryUsername() -> Bool {
        return primaryUsername != nil
    }
    
    func setPrimaryUsername(_ username: String) {
        guard let userDefaults = userDefaults else { return }
        primaryUsername = username
        userDefaults.set(username, forKey: UserDefaultsKeys.primaryLeetcodeUsername)
        
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
        guard let userDefaults = userDefaults else { return }
        userDefaults.set(savedUsernames, forKey: UserDefaultsKeys.leetcodeUsernames)
    }
}

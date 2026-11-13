//
//  SavedUsersViewModel.swift
//  ken
//
//  Created by Lakshay Gupta on 31/01/25.
//

import SwiftUI

class SavedUsersViewModel: ObservableObject {
    @Published private(set) var savedSourceIDs: [TrackedSourceID] = []
    @Published private(set) var primarySourceID: TrackedSourceID?

    private var userDefaults: UserDefaults? {
        UserDefaults(suiteName: AppGroup)
    }

    // Preserved public surface for LeetCode callers.
    var savedUsernames: [String] { savedSourceIDs.filter { $0.kind == .leetcode }.map(\.identifier) }
    var primaryUsername: String? {
        guard primarySourceID?.kind == .leetcode else { return nil }
        return primarySourceID?.identifier
    }

    init() {
        loadSavedSourceIDs()
        if savedSourceIDs.isEmpty {
            migrateLegacyLeetCodeUsernamesIfNeeded()
        }
    }

    func hasPrimaryUsername() -> Bool {
        return primaryUsername != nil
    }

    func setPrimaryUsername(_ username: String) {
        setPrimary(TrackedSourceID(kind: .leetcode, identifier: username))
    }

    func changePrimaryUsername(_ username: String) {
        if !savedUsernames.contains(username) {
            return
        }

        setPrimaryUsername(username)
    }

    func addUsername(_ username: String) {
        add(TrackedSourceID(kind: .leetcode, identifier: username))
    }

    func removeUsername(_ username: String) {
        if username == primaryUsername {
            return
        }

        remove(TrackedSourceID(kind: .leetcode, identifier: username))
    }

    // MARK: - Generic source plumbing

    private func add(_ id: TrackedSourceID) {
        guard !savedSourceIDs.contains(id) else { return }
        savedSourceIDs.append(id)
        persist()
    }

    private func remove(_ id: TrackedSourceID) {
        guard let index = savedSourceIDs.firstIndex(of: id) else { return }
        savedSourceIDs.remove(at: index)
        persist()
    }

    private func setPrimary(_ id: TrackedSourceID) {
        primarySourceID = id
        userDefaults?.set(id.storageKey, forKey: UserDefaultsKeys.primaryTrackedSourceID)
        add(id)
    }

    private func loadSavedSourceIDs() {
        guard let userDefaults = userDefaults else { return }
        let keys = userDefaults.stringArray(forKey: UserDefaultsKeys.trackedSourceIDs) ?? []
        savedSourceIDs = keys.compactMap(TrackedSourceID.init(storageKey:))
        if let primaryKey = userDefaults.string(forKey: UserDefaultsKeys.primaryTrackedSourceID) {
            primarySourceID = TrackedSourceID(storageKey: primaryKey)
        }
    }

    private func persist() {
        userDefaults?.set(savedSourceIDs.map(\.storageKey), forKey: UserDefaultsKeys.trackedSourceIDs)
    }

    /// One-time, additive, non-destructive: reads the legacy keys (never deletes
    /// them — the widget extension still reads them directly) and seeds the new
    /// composite-key store from them.
    private func migrateLegacyLeetCodeUsernamesIfNeeded() {
        guard let userDefaults = userDefaults else { return }
        let legacyUsernames = userDefaults.stringArray(forKey: UserDefaultsKeys.leetcodeUsernames) ?? []
        guard !legacyUsernames.isEmpty else { return }
        savedSourceIDs = legacyUsernames.map { TrackedSourceID(kind: .leetcode, identifier: $0) }
        if let legacyPrimary = userDefaults.string(forKey: UserDefaultsKeys.primaryLeetcodeUsername) {
            primarySourceID = TrackedSourceID(kind: .leetcode, identifier: legacyPrimary)
        }
        persist()
    }
}

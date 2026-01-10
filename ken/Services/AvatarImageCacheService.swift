//
//  AvatarImageCacheService.swift
//  ken
//
//  Created by Assistant on 16/09/25.
//

import Foundation
import UIKit

final class AvatarImageCacheService {
    static let shared = AvatarImageCacheService()
    static let avatarUpdatedNotification = Notification.Name("AvatarImageCacheService.avatarUpdated")
    
    private let fileManager = FileManager.default
    private let userDefaults: UserDefaults
    private let avatarURLMapKey = "avatar_url_map"
    
    private init() {
        self.userDefaults = UserDefaults(suiteName: AppGroup)!
        createCacheDirectoryIfNeeded()
    }
    
    // MARK: - Public API
    func cachedAvatar(for username: String) -> UIImage? {
        guard let url = fileURL(for: username), fileManager.fileExists(atPath: url.path) else {
            print("[AvatarCache] No cached image for \(username)")
            return nil
        }
        print("[AvatarCache] Using cached image for \(username) at \(url.lastPathComponent)")
        return UIImage(contentsOfFile: url.path)
    }
    
    func currentAvatarURLString(for username: String) -> String? {
        avatarURLMap()[username]
    }
    
    func saveAvatarURLString(_ urlString: String?, for username: String) {
        var map = avatarURLMap()
        map[username] = urlString
        userDefaults.set(map, forKey: avatarURLMapKey)
        userDefaults.synchronize()
    }
    
    func needsDownload(for username: String, remoteURLString: String?, force: Bool) -> Bool {
        if force { return true }
        guard let remote = remoteURLString, !remote.isEmpty else { return false }
        let stored = currentAvatarURLString(for: username)
        if stored != remote {
            print("[AvatarCache] URL changed for \(username). Old: \(stored ?? "nil"), New: \(remote)")
            return true
        }
        if let url = fileURL(for: username) {
            let exists = fileManager.fileExists(atPath: url.path)
            if !exists { print("[AvatarCache] File missing for \(username), will download") }
            return !exists
        }
        return true
    }
    
    func downloadAndCacheAvatar(for username: String, remoteURLString: String, completion: ((Bool) -> Void)? = nil) {
        guard let remoteURL = URL(string: remoteURLString) else { completion?(false); return }
        let request = URLRequest(url: remoteURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil, let image = UIImage(data: data) else {
                print("[AvatarCache] Download failed for \(username): \(error?.localizedDescription ?? "unknown error")")
                completion?(false)
                return
            }
            guard let fileURL = self.fileURL(for: username) else { completion?(false); return }
            do {
                try data.write(to: fileURL, options: .atomic)
                self.saveAvatarURLString(remoteURLString, for: username)
                print("[AvatarCache] Downloaded and cached avatar for \(username) -> \(fileURL.lastPathComponent)")
                NotificationCenter.default.post(name: AvatarImageCacheService.avatarUpdatedNotification, object: username)
                completion?(true)
            } catch {
                print("[AvatarCache] Failed to write avatar for \(username): \(error)")
                completion?(false)
            }
        }.resume()
    }
    
    // MARK: - Private
    private func avatarURLMap() -> [String: String] {
        userDefaults.dictionary(forKey: avatarURLMapKey) as? [String: String] ?? [:]
    }
    
    private func fileURL(for username: String) -> URL? {
        guard let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: AppGroup) else { return nil }
        let dir = containerURL.appendingPathComponent("Avatars", isDirectory: true)
        return dir.appendingPathComponent("\(username).png")
    }
    
    private func createCacheDirectoryIfNeeded() {
        guard let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: AppGroup) else { return }
        let dir = containerURL.appendingPathComponent("Avatars", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
    }
}



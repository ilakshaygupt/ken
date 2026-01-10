//
//  UserAvatarView.swift
//  ken
//
//  Created by Lakshay Gupta on 20/05/25.
//
import SwiftUI

struct UserAvatarView: View {
    let userProfile: UserProfile?
    let animate: Bool
    @State private var cachedImage: UIImage?
    @State private var observedUsername: String = ""
    
    private var currentUsername: String? { userProfile?.username }
    private var currentAvatarURL: String? { userProfile?.userAvatar }
    
    var body: some View {
        Group {
            if let image = cachedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .opacity(animate ? 1 : 0)
                    .scaleEffect(animate ? 1 : 0.8)
                    .offset(x: animate ? 0 : 20)
            } else if let username = currentUsername,
                      let avatarUrl = currentAvatarURL,
                      !avatarUrl.isEmpty {
                if let uiImage = AvatarImageCacheService.shared.cachedAvatar(for: username) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .opacity(animate ? 1 : 0)
                        .scaleEffect(animate ? 1 : 0.8)
                        .offset(x: animate ? 0 : 20)
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundColor(.blue)
                        .frame(width: 60, height: 60)
                        .opacity(animate ? 1 : 0)
                        .scaleEffect(animate ? 1 : 0.8)
                        .offset(x: animate ? 0 : 20)
                        .onAppear {
                            print("[AvatarView] Missing cache, downloading avatar for \(username)")
                            AvatarImageCacheService.shared.downloadAndCacheAvatar(for: username, remoteURLString: avatarUrl) { success in
                                if success {
                                    DispatchQueue.main.async {
                                        self.cachedImage = AvatarImageCacheService.shared.cachedAvatar(for: username)
                                        print("[AvatarView] Downloaded -> showing cached avatar for \(username)")
                                    }
                                }
                            }
                        }
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                    .opacity(animate ? 1 : 0)
                    .scaleEffect(animate ? 1 : 0.8)
                    .offset(x: animate ? 0 : 20)
            }
        }
        .onAppear {
            if let username = currentUsername {
                observedUsername = username
                cachedImage = AvatarImageCacheService.shared.cachedAvatar(for: username)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: AvatarImageCacheService.avatarUpdatedNotification)) { notif in
            if let updatedUsername = notif.object as? String, updatedUsername == observedUsername {
                cachedImage = AvatarImageCacheService.shared.cachedAvatar(for: updatedUsername)
            }
        }
        .onChange(of: currentUsername) { newUsername in
            guard let newUsername = newUsername else { return }
            observedUsername = newUsername
            cachedImage = AvatarImageCacheService.shared.cachedAvatar(for: newUsername)
        }
    }
}








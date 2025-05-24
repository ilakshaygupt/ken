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
    
    var body: some View {
        if let userProfile = userProfile,
           let avatarUrl = userProfile.userAvatar,
           !avatarUrl.isEmpty {
            
            AsyncImage(url: URL(string: avatarUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundColor(.blue)
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            .opacity(animate ? 1 : 0)
            .scaleEffect(animate ? 1 : 0.8)
            .offset(x: animate ? 0 : 20)
        } else {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
                .opacity(animate ? 1 : 0)
                .scaleEffect(animate ? 1 : 0.8)
                .offset(x: animate ? 0 : 20)
        }
    }
}








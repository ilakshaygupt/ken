//
//  UserProfile.swift
//  ken
//
//  Created by Lakshay Gupta on 04/05/25.
//


struct UserProfile: Identifiable {
    var id: String { username }
    let username: String
    let githubUrl: String?
    let twitterUrl: String?
    let linkedinUrl: String?
    let userAvatar: String?
    let realName: String?
    let aboutMe: String?
    let school: String?
    let websites: [String]
    let countryName: String?
    let company: String?
    let jobTitle: String?
    let skillTags: [String]
    let ranking: Int
    let contestBadge: ContestBadge?
}

struct ContestBadge {
    let name: String
    let expired: Bool
    let hoverText: String
    let icon: String
}
//
//  LeetCodeAPIClient.swift
//  ken
//
//  Created by Lakshay Gupta on 30/04/25.
//

import Alamofire
import Foundation
import Combine

public class LeetCodeAPIClient {
    private static let baseURL = URL(string: "https://leetcode.com/graphql")!
    private static let storageService = LeetCodeJSONStorageService()
    
    private static func createRequest(query: String, variables: [String: Any], operationName: String? = nil) -> URLRequest {
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("https://leetcode.com", forHTTPHeaderField: "Referer")
        
        var body: [String: Any] = [
            "query": query,
            "variables": variables
        ]
        
        if let operationName = operationName {
            body["operationName"] = operationName
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        return request
    }
    
    public static func getUserStats(for username: String, queue: DispatchQueue) -> Future<UserStats, Error> {
        Future { promise in
            queue.async {
                let variables = ["username": username]
                let request = createRequest(query: GraphQLQueries.userStats, variables: variables)
                
                AF.request(request)
                    .validate()
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            do {
                                // Save raw JSON response first
                                storageService.saveStatsJSONResponse(data, forUsername: username)
                                
                                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                                guard let dataObj = json?["data"] as? [String: Any],
                                      let matchedUser = dataObj["matchedUser"] as? [String: Any],
                                      let submitStats = matchedUser["submitStats"] as? [String: Any],
                                      let acSubmissionNum = submitStats["acSubmissionNum"] as? [[String: Any]],
                                      let totalSubmissionNum = submitStats["totalSubmissionNum"] as? [[String: Any]],
                                      let allQuestionsCount = dataObj["allQuestionsCount"] as? [[String: Any]] else {
                                    throw URLError(.cannotParseResponse)
                                }
                                
                                var easySolved = 0
                                var mediumSolved = 0
                                var hardSolved = 0
                                
                                for submission in acSubmissionNum {
                                    if let difficulty = submission["difficulty"] as? String,
                                       let count = submission["count"] as? Int {
                                        switch difficulty {
                                        case "Easy": easySolved = count
                                        case "Medium": mediumSolved = count
                                        case "Hard": hardSolved = count
                                        default: break
                                        }
                                    }
                                }
                                
                                var easyTotal = 0
                                var mediumTotal = 0
                                var hardTotal = 0
                                
                                for questionCount in allQuestionsCount {
                                    if let difficulty = questionCount["difficulty"] as? String,
                                       let count = questionCount["count"] as? Int {
                                        switch difficulty {
                                        case "Easy": easyTotal = count
                                        case "Medium": mediumTotal = count
                                        case "Hard": hardTotal = count
                                        default: break
                                        }
                                    }
                                }
                                
                                let totalSolved = easySolved + mediumSolved + hardSolved
                                let totalProblems = easyTotal + mediumTotal + hardTotal
                                
                                var totalAccepted = 0
                                var totalSubmitted = 0
                                
                                for submission in totalSubmissionNum {
                                    if let count = submission["count"] as? Int {
                                        totalSubmitted += count
                                    }
                                }
                                
                                for submission in acSubmissionNum {
                                    if let count = submission["count"] as? Int {
                                        totalAccepted += count
                                    }
                                }
                                
                                let profile = matchedUser["profile"] as? [String: Any]
                                let ranking = profile?["ranking"] as? Int
                                
                                let stats = UserStats(
                                    totalSolved: totalSolved,
                                    easySolved: easySolved,
                                    mediumSolved: mediumSolved,
                                    hardSolved: hardSolved,
                                    easyTotal: easyTotal,
                                    mediumTotal: mediumTotal,
                                    hardTotal: hardTotal,
                                    totalProblems: totalProblems,
                                    ranking: ranking ?? 0
                                )
                                
                                promise(.success(stats))
                            } catch {
                                promise(.failure(error))
                            }
                        case .failure(let error):
                            promise(.failure(error))
                        }
                    }
            }
        }
    }
    
    static func getUserCalendar(for username: String, queue: DispatchQueue) -> Future<UserCalendar, Error> {
        Future { promise in
            queue.async {
                let variables = ["username": username]
                let request = createRequest(
                    query: GraphQLQueries.userCalendar,
                    variables: variables,
                    operationName: "userProfileCalendar"
                )
                
                AF.request(request)
                    .validate()
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            do {
                                storageService.saveCalendarJSONResponse(data, forUsername: username)
                                
                                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                                guard let jsonData = json?["data"] as? [String: Any],
                                      let matchedUser = jsonData["matchedUser"] as? [String: Any],
                                      let calendar = matchedUser["userCalendar"] as? [String: Any] else {
                                    throw URLError(.cannotParseResponse)
                                }
                                
                                let activeYears = calendar["activeYears"] as? [Int] ?? []
                                let streak = calendar["streak"] as? Int ?? 0
                                let totalActiveDays = calendar["totalActiveDays"] as? Int ?? 0
                                let submissionCalendar = calendar["submissionCalendar"] as? String ?? "{}"
                                let dccBadgesData = calendar["dccBadges"] as? [[String: Any]] ?? []
                                let dccBadges = dccBadgesData.compactMap { badgeData -> Badge? in
                                    guard let timestamp = badgeData["timestamp"] as? Int,
                                          let badge = badgeData["badge"] as? [String: Any],
                                          let name = badge["name"] as? String,
                                          let icon = badge["icon"] as? String else {
                                        return nil
                                    }
                                    return Badge(name: name, icon: icon, timestamp: timestamp)
                                }
                                
                                let calendars = UserCalendar(
                                    activeYears: activeYears,
                                    streak: streak,
                                    totalActiveDays: totalActiveDays,
                                    submissionCalendar: submissionCalendar,
                                    dccBadges: dccBadges
                                )
                                
                                promise(.success(calendars))
                            } catch {
                                promise(.failure(error))
                            }
                        case .failure(let error):
                            promise(.failure(error))
                        }
                    }
            }
        }
    }
    
    static func getUserProfile(for username: String, queue: DispatchQueue) -> Future<(UserProfile, Data), Error> {
        Future { promise in
            queue.async {
                let variables = ["username": username]
                let request = createRequest(
                    query: GraphQLQueries.userProfile,
                    variables: variables,
                    operationName: "userPublicProfile"
                )
                
                AF.request(request)
                    .validate()
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            do {
                                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                                guard let jsonData = json?["data"] as? [String: Any],
                                      let matchedUser = jsonData["matchedUser"] as? [String: Any] else {
                                    throw URLError(.cannotParseResponse)
                                }
                                
                                let username = matchedUser["username"] as? String ?? ""
                                let githubUrl = matchedUser["githubUrl"] as? String
                                let twitterUrl = matchedUser["twitterUrl"] as? String
                                let linkedinUrl = matchedUser["linkedinUrl"] as? String
                                
                                let profile = matchedUser["profile"] as? [String: Any]
                                let userAvatar = profile?["userAvatar"] as? String
                                let realName = profile?["realName"] as? String
                                let aboutMe = profile?["aboutMe"] as? String
                                let school = profile?["school"] as? String
                                let websites = profile?["websites"] as? [String] ?? []
                                let countryName = profile?["countryName"] as? String
                                let company = profile?["company"] as? String
                                let jobTitle = profile?["jobTitle"] as? String
                                let skillTags = profile?["skillTags"] as? [String] ?? []
                                let ranking = profile?["ranking"] as? Int ?? 0
                                
                                let contestBadgeData = matchedUser["contestBadge"] as? [String: Any]
                                var contestBadge: ContestBadge? = nil
                                if let badgeData = contestBadgeData {
                                    let name = badgeData["name"] as? String ?? ""
                                    let expired = badgeData["expired"] as? Bool ?? false
                                    let hoverText = badgeData["hoverText"] as? String ?? ""
                                    let icon = badgeData["icon"] as? String ?? ""
                                    contestBadge = ContestBadge(name: name, expired: expired, hoverText: hoverText, icon: icon)
                                }
                                
                                let userProfile = UserProfile(
                                    username: username,
                                    githubUrl: githubUrl,
                                    twitterUrl: twitterUrl,
                                    linkedinUrl: linkedinUrl,
                                    userAvatar: userAvatar,
                                    realName: realName,
                                    aboutMe: aboutMe,
                                    school: school,
                                    websites: websites,
                                    countryName: countryName,
                                    company: company,
                                    jobTitle: jobTitle,
                                    skillTags: skillTags,
                                    ranking: ranking,
                                    contestBadge: contestBadge
                                )
                                
                                promise(.success((userProfile, data)))
                            } catch {
                                promise(.failure(error))
                            }
                        case .failure(let error):
                            promise(.failure(error))
                        }
                    }
            }
        }
    }
}
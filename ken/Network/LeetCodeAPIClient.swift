//
//  LeetCodeAPIClient.swift
//  ken
//
//  Created by Lakshay Gupta on 30/04/25.
//


//
//  LeetCodeAPIClient.swift
//  LeetCode
//
//  Created by Lakshay Gupta on 25/01/25.
//

import Foundation
import Combine

public class LeetCodeAPIClient {
    private static let baseURL = URL(string: "https://leetcode.com/graphql")!
    
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
                
                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    guard let data = data else {
                        promise(.failure(URLError(.badServerResponse)))
                        return
                    }
                    
                    do {
                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                        guard let data = json?["data"] as? [String: Any],
                              let matchedUser = data["matchedUser"] as? [String: Any],
                              let submitStats = matchedUser["submitStats"] as? [String: Any],
                              let acSubmissionNum = submitStats["acSubmissionNum"] as? [[String: Any]],
                              let totalSubmissionNum = submitStats["totalSubmissionNum"] as? [[String: Any]],
                              let allQuestionsCount = data["allQuestionsCount"] as? [[String: Any]] else {
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
                }.resume()
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
                
                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    guard let data = data else {
                        promise(.failure(URLError(.badServerResponse)))
                        return
                    }
                    
                    do {
                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                        guard let data = json?["data"] as? [String: Any],
                              let matchedUser = data["matchedUser"] as? [String: Any],
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
                }.resume()
            }
        }
    }
}

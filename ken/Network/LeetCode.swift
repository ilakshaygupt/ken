//
//  LeetCode.swift
//  ken
//
//  Created by Lakshay Gupta on 25/01/25.
//


import Combine
import Foundation

public enum LeetCode  {
    // MARK: - Models
    
    public struct UserStats {
        public let totalSolved: Int
        public let easySolved: Int
        public let mediumSolved: Int
        public let hardSolved: Int
        public let acceptanceRate: Double
        public let ranking: Int
    }
    
    public struct UserCalendar {
        public let activeYears: [Int]
        public let streak: Int
        public let totalActiveDays: Int
        public let submissionCalendar: String
        
        public struct Badge {
            public let name: String
            public let icon: String
            public let timestamp: Int
        }
        public let dccBadges: [Badge]
        
        public struct DailyContribution {
            public let date: Date
            public let count: Int
            
            public static func parse(from calendar: String) -> [DailyContribution] {
                guard let data = calendar.data(using: .utf8),
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Int] else {
                    return []
                }
                
                return json.compactMap { dateString, count in
                    guard let timestampDouble = Double(dateString) else {
                        return nil
                    }
                    let date = Date(timeIntervalSince1970: timestampDouble)
                    return DailyContribution(date: date, count: count)
                }
            }
        }
    }
    
    // MARK: - Public Methods
    
    public static func getUserStats(for username: String, queue: DispatchQueue) -> Future<UserStats, Error> {
        Future { promise in
            queue.async {
                let query = """
                query getUserProfile($username: String!) {
                    matchedUser(username: $username) {
                        submitStats {
                            totalSubmissionNum {
                                difficulty
                                count
                            }
                            acSubmissionNum {
                                difficulty
                                count
                            }
                        }
                        profile {
                            ranking
                            reputation
                        }
                    }
                }
                """
                
                let variables = ["username": username]
                
                var request = URLRequest(url: URL(string: "https://leetcode.com/graphql")!)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("https://leetcode.com", forHTTPHeaderField: "Referer")
                
                let body = [
                    "query": query,
                    "variables": variables
                ] as [String : Any]
                
                request.httpBody = try? JSONSerialization.data(withJSONObject: body)
                
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
                              let profile = matchedUser["profile"] as? [String: Any] else {
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
                        
                        let totalSolved = easySolved + mediumSolved + hardSolved
                        let ranking = (profile["ranking"] as? Int) ?? 0
                        
                        let stats = UserStats(
                            totalSolved: totalSolved,
                            easySolved: easySolved,
                            mediumSolved: mediumSolved,
                            hardSolved: hardSolved,
                            acceptanceRate: 0.0, 
                            ranking: ranking
                        )
                        
                        promise(.success(stats))
                    } catch {
                        promise(.failure(error))
                    }
                }.resume()
            }
        }
    }
    
    public static func getUserCalendar(for username: String, queue: DispatchQueue) -> Future<UserCalendar, Error> {
        Future { promise in
            queue.async {
                let query = """
                query userProfileCalendar($username: String!, $year: Int) {
                    matchedUser(username: $username) {
                        userCalendar(year: $year) {
                            activeYears
                            streak
                            totalActiveDays
                            dccBadges {
                                timestamp
                                badge {
                                    name
                                    icon
                                }
                            }
                            submissionCalendar
                        }
                    }
                }
                """
                
                let variables = ["username": username]
                
                var request = URLRequest(url: URL(string: "https://leetcode.com/graphql")!)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("https://leetcode.com", forHTTPHeaderField: "Referer")
                
                let body = [
                    "query": query,
                    "variables": variables,
                    "operationName": "userProfileCalendar"
                ] as [String : Any]
                
                request.httpBody = try? JSONSerialization.data(withJSONObject: body)
                
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
                        let dccBadges = dccBadgesData.compactMap { badgeData -> UserCalendar.Badge? in
                            guard let timestamp = badgeData["timestamp"] as? Int,
                                  let badge = badgeData["badge"] as? [String: Any],
                                  let name = badge["name"] as? String,
                                  let icon = badge["icon"] as? String else {
                                return nil
                            }
                            return UserCalendar.Badge(name: name, icon: icon, timestamp: timestamp)
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

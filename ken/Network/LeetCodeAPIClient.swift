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
import Alamofire
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
                
                AF.request(request)
                    .validate()
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            do {
                                promise(.success(LeetCodeJSONParser.parseUserStats(from: data)!))
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
                    .responseJSON { response in
                        switch response.result {
                        case .success(let json):
                            if let jsonData = try? JSONSerialization.data(withJSONObject: json) {
                                promise(.success(LeetCodeJSONParser.parseUserCalendar(from: jsonData)!))
                            } else {
                                promise(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert JSON to Data"])))
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
                                if let profile = LeetCodeJSONParser.parseUserProfile(from: data) {
                                    promise(.success((profile, data)))
                                } else {
                                    promise(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse user profile"])))
                                }
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

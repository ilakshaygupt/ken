//
//  UserDetailView.swift
//  ken
//
//  Created by Lakshay Gupta on 24/04/25.
//

import SwiftUI

struct UserDetailView: View {
    let username: String
    @ObservedObject var leetCodeVM: LeetCodeViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                VStack(alignment: .leading, spacing: 8) {
                    Text(username)
                        .font(.title)
                        .bold()
                    
                    
                    
                    if let stats = leetCodeVM.userStats[username] {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Statistics")
                                .font(.title2)
                                .bold()
                            
                            StatsView(stats: stats)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                    
                    if let calendar = leetCodeVM.userCalendars[username] {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Activity")
                                .font(.title2)
                                .bold()
                            
                            CalendarView(calendar: calendar)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
        }
    }
}

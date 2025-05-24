//
//  DetailCardView.swift
//  ken
//
//  Created by Lakshay Gupta on 20/05/25.
//

import SwiftUI

struct DetailCardView: View {
    let cardType: HomeCardType
    let stats: UserStats
    let calendar: UserCalendar
    @Environment(\.dismiss) private var dismiss
    @State private var animateContent = false
    @Environment(\.colorScheme) private var colorScheme
    
    private var backgroundColor: Color {
        AppTheme.shared.backgroundColor(in: colorScheme)
    }
    
    private var cardBackgroundColor: Color {
        AppTheme.shared.cardBackgroundColor(in: colorScheme)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    switch cardType {
                    case .stats:
                        StatsCardView(stats: stats)
                            .padding(.horizontal)
                    case .graph:
                        VStack(spacing: 12) {
                            ContributionsView(
                                contributions: calendar.contributions,
                                monthsToShow: 24
                            )
                            
                            // Additional stats could go here
                            Text("Total Contributions: \(calendar.contributions.count)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding()
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 30)
            }
            .navigationTitle(cardType.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .background(backgroundColor)
            .onAppear {
                withAnimation(.easeOut(duration: 0.3)) {
                    animateContent = true
                }
            }
        }
        .background(backgroundColor)
    }
}

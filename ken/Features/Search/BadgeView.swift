//
//  BadgeView.swift
//  ken
//
//  Created by Lakshay Gupta on 31/01/25.
//

import SwiftUI
import Combine
import WidgetKit


struct BadgeView: View {
    let badge: LeetCode.UserCalendar.Badge
    
    var body: some View {
        VStack(spacing: 4) {
            AsyncImage(url: URL(string: badge.icon)) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 40, height: 40)
            
            Text(badge.name)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80)
        .padding(8)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}

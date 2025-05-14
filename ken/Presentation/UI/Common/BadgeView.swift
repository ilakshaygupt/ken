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
    let baseURL = "https://leetcode.com"

    let badge: Badge
    
    var body: some View {
        VStack(spacing: 4) {
            
            AsyncImage(url: URL(string: baseURL + badge.icon)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .background(Color.clear)
                    .blendMode(.multiply)
                    .clipShape(Circle())
                    .shadow(radius: 5)

            } placeholder: {
                ProgressView()
            }
            .frame(width: 70, height: 70)
        }
        .frame(width: 80)
        .padding(8)
        .background(Color.clear)
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}

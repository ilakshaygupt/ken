//
//  StatCard.swift
//  ken
//
//  Created by Lakshay Gupta on 31/01/25.
//
import SwiftUI
import Combine
import WidgetKit




struct StatCard: View {
    let title: String
    let value: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.headline)
            Text("\(value)")
                .font(.title)
                .bold()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

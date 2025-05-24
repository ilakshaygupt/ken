//
//  HomeCardType.swift
//  ken
//
//  Created by Lakshay Gupta on 20/05/25.
//
import SwiftUI


enum HomeCardType: String, CaseIterable {
    case stats = "Statistics"
    case graph = "Activity Graph"
    
    var systemImage: String {
        switch self {
        case .stats: return "chart.bar"
        case .graph: return "calendar"
        }
    }
    
    var gradient: [Color] {
        switch self {
        case .stats: return [Color.blue, Color.blue.opacity(0.7)]
        case .graph: return [Color.indigo, Color.indigo.opacity(0.7)]
        }
    }
}

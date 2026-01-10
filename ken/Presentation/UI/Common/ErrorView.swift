//
//  ErrorView.swift
//  ken
//
//  Created by Lakshay Gupta on 31/01/25.
//

import SwiftUI
import Combine
import WidgetKit


struct ErrorView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(UIConstants.bodyFont)
            .foregroundColor(.red)
            .padding(UIConstants.padding)
            .background(Color.red.opacity(0.1))
            .cornerRadius(UIConstants.cornerRadiusSmall)
    }
}

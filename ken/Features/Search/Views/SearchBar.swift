//
//  ContentView.swift
//  ken
//
//  Created by Lakshay Gupta on 24/01/25.
//

import SwiftUI
import Combine
import WidgetKit

 
struct SearchBar: View {
    @Binding var username: String
    let onSearch: () -> Void
    
    var body: some View {
        HStack {
            TextField("Enter LeetCode username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            Button(action: onSearch) {
                Text("Search")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(username.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(username.isEmpty)
        }
    }
}

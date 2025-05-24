//
//  CardView.swift
//  ken
//
//  Created by Lakshay Gupta on 20/05/25.
//
import SwiftUI


struct CardView<Content: View>: View {
    let title: String
    let systemImage: String
    let gradient: [Color]
    let animate: Bool
    let content: Content
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var cardBackgroundColor: Color {
        AppTheme.shared.cardBackgroundColor(in: colorScheme)
    }
    
    init(title: String, systemImage: String, gradient: [Color], animate: Bool, @ViewBuilder content: () -> Content) {
        self.title = title
        self.systemImage = systemImage
        self.gradient = gradient
        self.animate = animate
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Section Header
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 30, height: 30)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: gradient),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            content
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(cardBackgroundColor)
                )
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(cardBackgroundColor)
        )
        .opacity(animate ? 1 : 0)
        .offset(y: animate ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: animate)
    }
}

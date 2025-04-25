//
//  MultiArcProgressView.swift
//  ken
//
//  Created by Lakshay Gupta on 25/04/25.
//

import SwiftUI

struct MultiArcProgressView: View {
    @Environment(\.widgetFamily) var family
    let easyProgress: Double
    let mediumProgress: Double
    let hardProgress: Double
    let lineWidth: CGFloat
    let totalQuestions : Int
    let solvedQuestion : Int
    
    var body: some View {
        ZStack {
            Arc(startAngle: .degrees(135), endAngle: .degrees(205))
                .stroke(
                    Color.green.opacity(0.2),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
            
            Arc(startAngle: .degrees(135), endAngle: .degrees(135 + 90 * (easyProgress)))
                .stroke(
                    Color.green,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
            
            
            
            Arc(startAngle: .degrees(225), endAngle: .degrees(315))
                .stroke(
                    Color.yellow.opacity(0.2),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
            
            Arc(startAngle: .degrees(225), endAngle: .degrees(225 + 90 * mediumProgress))
                .stroke(
                    Color.yellow,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )

            Arc(startAngle: .degrees(-25), endAngle: .degrees(45))
                .stroke(
                    Color.red.opacity(0.2),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
            Arc(startAngle: .degrees(-25), endAngle: .degrees(-25 + 90 * hardProgress))
                .stroke(
                    Color.red,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
            
            VStack {
                    Text("\(solvedQuestion)")
                    .font(.system(size: family == .systemSmall ? 16 : 18))
                    .fontWeight(.bold)
                            
                    Text("/ \(totalQuestions)")
                    .font(.system(size: family == .systemSmall ? 13 : 15))
                    .foregroundColor(.gray)
            }
        }
    }
}

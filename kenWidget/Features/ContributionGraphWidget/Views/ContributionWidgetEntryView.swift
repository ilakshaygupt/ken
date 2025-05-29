//
//  ContributionWidgetEntryView.swift
//  ken
//
//  Created by Lakshay Gupta on 25/04/25.
//

import WidgetKit
import SwiftUI


struct ContributionWidgetEntryView: View {
    var entry: ContributionWidgetEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 5) {
                Image("icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)

                Text(entry.username)
                    .font(.system(.caption2,design: .monospaced))
                    .bold()
            }
            .frame(maxWidth: .infinity)

            ContributionGridWidgetView(contributions: entry.contributions)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, alignment: .center) 
        .multilineTextAlignment(.center)
        .widgetURL(URL(string: "leetcode://user/\(entry.username)"))
    }
}

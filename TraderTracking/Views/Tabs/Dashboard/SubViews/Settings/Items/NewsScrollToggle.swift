//
//  NewsScrollButton.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 4/17/23.
//

import SwiftUI


struct NewsScrollToggle: View {
    @Binding var newsDoesScrollToToday: Bool
    
    var body: some View {
            Toggle(isOn: $newsDoesScrollToToday) {
                Text("News Scrolls to Today")
            }
    }
}

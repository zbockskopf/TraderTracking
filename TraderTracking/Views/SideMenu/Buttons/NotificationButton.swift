//
//  NavigationButton.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 9/29/22.
//

import SwiftUI

struct NotificationButton: View {
    
    @Binding var showNotificationSettings: Bool
    @Binding var xOffset: CGFloat
    var screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        HStack(alignment: .center){
            Button {
                xOffset = -screenWidth * 0.8
                showNotificationSettings.toggle()
            } label: {
                Image(systemName: "bell")
                Text("Notifications")
            }
        }
        .foregroundColor(Color(UIColor.label))
        .scaledToFit()
 
    }
}


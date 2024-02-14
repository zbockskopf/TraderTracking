//
//  NavigationButton.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 9/29/22.
//

import SwiftUI

struct NotificationButton: View {
    
    @Binding var showNotificationSettings: Bool
    @Binding var showMenu: Bool
    var screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        HStack(alignment: .center){
            Button {
//                xOffset = -screenWidth * 0.8
                
                showNotificationSettings.toggle()
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    showMenu.toggle()
//                }

                
                
            } label: {
                Image(systemName: "bell")
                Text("Notifications")
            }
        }
        .foregroundColor(Color(UIColor.label))
        .padding()
        .scaledToFit()
 
    }
}


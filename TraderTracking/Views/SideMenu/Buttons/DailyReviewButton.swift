//
//  DailyReview.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 6/29/23.
//

import SwiftUI

struct DailyReviewButton: View {
    @Binding var showDailyReview: Bool
    @Binding var showMenu: Bool
    var screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        HStack(alignment: .center){
            Button {
//                xOffset = -screenWidth * 0.8
                
                showDailyReview.toggle()
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    showMenu.toggle()
//                }

                
                
            } label: {
                Image(systemName: "doc.text.magnifyingglass")
                Text("Reviews")
            }
        }
        .foregroundColor(Color(UIColor.label))
        .padding()
        .scaledToFit()
 
    }
}


//
//  ForexCalendarButton.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 9/29/22.
//

import SwiftUI

struct ForexCalendarButton: View {
    
    @Binding var showForexCalendar: Bool

    var screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        HStack(alignment: .center){
            Button{
//                xOffset = -screenWidth * 0.8
                showForexCalendar.toggle()
            } label: {
                Image(systemName: "calendar")
                Text("Forex Calendar")
                
            }
            .foregroundColor(Color(UIColor.label))
            .sheet(isPresented: $showForexCalendar) {
                NavigationStack{
                    WebView(url: URL(string: "https://www.forexfactory.com")!)
                        .navigationBarItems(
                            leading:
                                Button(action: {
                                    showForexCalendar.toggle()
                                }, label: {
                                    Text("Back")
                                        .foregroundColor(Color(UIColor.label))
                                    
                                })
                        )
                }
                
            }
        }
        .padding()
        .scaledToFit()
    }
}

//
//  ForexCalendarButton.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 9/29/22.
//

import SwiftUI

struct ForexCalendarButton: View {
    
    @Binding var showForexCalendar: Bool
    
    var body: some View {
        HStack(alignment: .center){
            Button{
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

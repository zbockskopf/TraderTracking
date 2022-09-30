//
//  MainTabView.swift
//  TraderTracking
//
//  Created by Zach on 9/16/22.
//

import SwiftUI

struct MainTabView: View {

    var realmController = RealmController()
    @EnvironmentObject var notifications: Notifications
    @StateObject var tradeListData = TradeListViewModel()
    @State private var selection = 0

    var screenWidth = UIScreen.main.bounds.width
    @State var xOffset: CGFloat = 0
    @State var currentXOffset: CGFloat = 0
    @Environment(\.colorScheme) var scheme
    
    @State var showNotificationSettings: Bool = false
    @State var showProfile: Bool = false
    

    var body: some View {
        GeometryReader { reader in
                                
            HStack(spacing: 0){
                
                SideMenu(currentXOffset: $currentXOffset, xOffset: $xOffset, showNotificationSettings: $showNotificationSettings, showProfile: $showProfile)
                    .frame(width: screenWidth * 0.8)
                    .environmentObject(realmController)
                    .environmentObject(notifications)

                ZStack{
                    TabView(selection: $selection) {
                        ContentView(showNotificationSettings: $showNotificationSettings, showProfile: $showProfile, currentXOffset: $currentXOffset, xOffset: $xOffset)
                            .tabItem {
                                selection == 0 ? Image("Tracker-Active") : Image("Tracker-Inactive")
                                Text("")
                            }
                            .environmentObject(realmController)
                            .environmentObject(notifications)
                            .tag(0)
                                .gesture( !showNotificationSettings ?
                                    DragGesture()
                                        .onChanged({ value in
                                            if value.startLocation.x < CGFloat(100.0){
                                                if value.translation.width > 0 && xOffset != 0 { // left to right
                                                    withAnimation {
                                                        xOffset = currentXOffset + value.translation.width
                                                    }
                                                } else if value.translation.width < 0 && xOffset != -screenWidth * 0.8 {
                                                    withAnimation {
                                                        xOffset = currentXOffset + value.translation.width
                                                    }
                                                }
                                            }
                                        })
                                        .onEnded({ value in
                                            if value.translation.width > 0 { // left to right
                                                withAnimation {
                                                    xOffset = 0
                                                }
                                            } else {
                                                withAnimation {
                                                    xOffset = -screenWidth * 0.8
                                                }
                                            }
                                            currentXOffset = xOffset
                                        }) : nil
                                )
                        TradesListView()
                            .tabItem {
                                selection == 1 ? Image("List-Active") : Image("List-Inactive")
                                Text("")
                            }
                            .environmentObject(realmController)
                            .environmentObject(tradeListData)
                            .tag(1)
//                        ImageUIView()
//                            .tag(2)

                    }
                    .frame(width: screenWidth)
                                        
                                            
                }
            }
        }
        .onAppear {
               xOffset = -screenWidth * 0.8 // hides the menu
               currentXOffset = xOffset
           }
           .offset(x: xOffset)


    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}

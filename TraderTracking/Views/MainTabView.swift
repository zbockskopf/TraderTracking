//
//  MainTabView.swift
//  TraderTracking
//
//  Created by Zach on 9/16/22.
//

import SwiftUI

struct MainTabView: View {

    var realmController = RealmController()
    var gestureController = GestureController()
    @EnvironmentObject var notifications: Notifications
    @StateObject var tradeListData = TradeListViewModel()
    @State private var selection = 0

    @Environment(\.colorScheme) var scheme
    
    @State var showNotificationSettings: Bool = false
    @State var showProfile: Bool = false
    

    var body: some View {
        GeometryReader { reader in
                                
            HStack(spacing: 0){
                
                SideMenu(showNotificationSettings: $showNotificationSettings, showProfile: $showProfile)
                    .frame(width: gestureController.screenWidth * 0.8)
                    

                ZStack{
                    TabView(selection: $selection) {
                        ContentView(showNotificationSettings: $showNotificationSettings, showProfile: $showProfile)
                            .tabItem {
                                selection == 0 ? Image("Tracker-Active") : Image("Tracker-Inactive")
                                Text("")
                            }
                            .tag(0)
                            .gesture( !showNotificationSettings ?
                                DragGesture()
                                    .onChanged({ value in
                                        if value.startLocation.x < CGFloat(100.0){
                                            if value.translation.width > 0 && gestureController.xOffset != 0 { // left to right
                                                withAnimation {
                                                    gestureController.xOffset = gestureController.currentXOffset + value.translation.width
                                                }
                                            } else if value.translation.width < 0 && gestureController.xOffset != -gestureController.screenWidth * 0.8 {
                                                withAnimation {
                                                    gestureController.xOffset = gestureController.currentXOffset + value.translation.width
                                                }
                                            }
                                        }
                                    })
                                    .onEnded({ value in
                                        if value.translation.width > 0 { // left to right
                                            withAnimation {
                                                gestureController.xOffset = 0
                                            }
                                        } else {
                                            withAnimation {
                                                gestureController.xOffset = -gestureController.screenWidth * 0.8
                                            }
                                        }
                                        gestureController.currentXOffset = gestureController.xOffset
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
                    .frame(width: gestureController.screenWidth)
                                        
                                            
                }
            }
            .environmentObject(realmController)
            .environmentObject(notifications)
            .environmentObject(gestureController)
        }
//        .onAppear {
//            gestureController.xOffset = -gestureController.screenWidth * 0.8 // hides the menu
//            gestureController.currentXOffset = gestureController.xOffset
//           }
        .offset(x: gestureController.xOffset)
//        .onChange(of: gestureController.gestureOffset) { newVaule in
//            gestureController.onChange()
//                }


    }
    
    
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}

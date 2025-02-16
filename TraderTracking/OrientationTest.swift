//
//  OrientationTest.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 11/14/22.
//

import Foundation
import SwiftUI

struct TestTabs: View {
    
    @EnvironmentObject var realmController: RealmController
    @StateObject var menuController = MenuController()
    @StateObject  var gestureController = GestureController()
    
    @EnvironmentObject var notifications: MyNotifications
    
    @StateObject var tradeListData = TradeListViewModel()
    @State private var selection = 1
    @State var showMenu: Bool = false
    @State var offSet: CGFloat = 0
    @State var lastStoredOffset: CGFloat = 0
    @State var showListView: Bool = false
    var screenWidth = UIScreen.main.bounds.width
    @Environment(\.colorScheme) var scheme
    @GestureState var gestureOffset: CGFloat = 0

    
    var body: some View {
        TabView(selection: $selection) {
            ContentView(showMenu: $showMenu, offSet: $offSet)
                .tabItem {
                    selection == 0 ? Image("Tracker-Active") : Image("Tracker-Inactive")
                    Text("")
                }
                .environmentObject(realmController)
                .environmentObject(notifications)
                .environmentObject(menuController)
                .tag(0)
                
            
//            TradesListView()
//                .tabItem {
//                    selection == 1 ? Image("List-Active") : Image("List-Inactive")
//                    Text("")
//                }
//                .environmentObject(realmController)
//                .environmentObject(tradeListData)
//                .environmentObject(menuController)
//                .tag(1)
            
//                        WebView(url: URL(string: "https://www.forexfactory.com")!)
//                            .tabItem {
//                                Image(systemName: "calendar")
//                            }
//                            .tag(2)
            
        }
    }
}

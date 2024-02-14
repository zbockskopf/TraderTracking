//
//  MainTabView.swift
//  TraderTracking
//
//  Created by Zach on 9/16/22.
//

import SwiftUI
import RealmSwift

struct MainTabView: View {

    @EnvironmentObject var realmController: RealmController
    @EnvironmentObject var notifications: MyNotifications
    @EnvironmentObject var newsController: ForexCrawler
    
    
    @StateObject var menuController = MenuController.shared
    @StateObject  var gestureController = GestureController()
    @StateObject var tradeListData = TradeListViewModel()
    
    @State private var selection = 0
    @State var showMenu: Bool = false
    @State var offSet: CGFloat = 0
    @State var lastStoredOffset: CGFloat = 0
    

    @GestureState var gestureOffset: CGFloat = 0

    var body: some View {
        let sideBarWidth = getRect().width - 90
        ZStack{
            HStack(spacing: 0){
                SideMenu(showMenu: $showMenu)
                    .frame(maxWidth: .infinity,alignment: .leading)
                            // Max Width...
                            .frame(width: getRect().width - 90)
                            .frame(maxHeight: .infinity)
                    .environmentObject(realmController)
                    .environmentObject(notifications)
                    .environmentObject(menuController)
                    .frame(maxWidth: .infinity,alignment: .leading)
                
                ZStack{
                    TabView(selection: $menuController.selection) {
//                        ContentView(showMenu: $showMenu, offSet: $offSet)
//                            .tabItem {
//                                menuController.selection == 0 ? Image("Tracker-Active") : Image("Tracker-Inactive")
//                                Text("")
//                            }
//                            
//                            .environmentObject(realmController)
//                            .environmentObject(notifications)
//                            .environmentObject(menuController)
//                            .environmentObject(newsController)
//                            .tag(0)
                        Dashboard(showMenu: $showMenu, offSet: $offSet)
                            .tabItem {
                                menuController.selection == 0 ? Image("Tracker-Active") : Image("Tracker-Inactive")
                                Text("")
                            }
                            
                            .environmentObject(realmController)
                            .environmentObject(notifications)
                            .environmentObject(menuController)
                            .environmentObject(newsController)
                            .tag(0)
                        
                        NewsPager()
                            .tabItem {
                                menuController.selection == 2 ?Image("News-Active") : Image("News-Inactive")
                                Text("")
                            }
                            .environmentObject(newsController)
                            .environmentObject(menuController)
                            .tag(2)
                        
//                        JournalView(weekNumber: "Week 39")
//                            .tabItem {
//                                menuController.selection == 3 ? Image(systemName: "doc.text.magnifyingglass").foregroundStyle(.green) : Image(systemName: "doc.text.magnifyingglass").foregroundStyle(.black)
//                                Text("")
//                            }
//                            .environmentObject(realmController)
//                            .tag(3)
                            
                        TradesListView(account: realmController.account)
                            .tabItem {
                                menuController.selection == 1 ? Image("List-Active") : Image("List-Inactive")
                                Text("")
                            }
                            .environmentObject(realmController)
                            .environmentObject(tradeListData)
                            .environmentObject(menuController)
                            .environmentObject(newsController)
                            .tag(1)
                        
                    }
                    
                    .frame(width: getRect() .width)
                    .onChange(of: menuController.selection) { val in
                        if val == 1 || val == 2 || val == 3{
                            menuController.showListView = true
                        }else{
                            menuController.showListView = false
                        }
                    }
                }
            }
            .frame(width: getRect().width + sideBarWidth)
            .offset(x: -sideBarWidth / 2)
            .offset(x: offSet > 0 ? offSet : 0)
            .gesture( !menuController.showListView ?

                    DragGesture()
                        .updating($gestureOffset, body: { value, out, _ in
                            out = value.translation.width
                            
                        })
                        .onEnded(onEnd(value:))
                      : nil
            )
        }
        .onAppear{
                let appearance = UITabBarAppearance()
                appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
                appearance.backgroundColor = UIColor(Color.clear.opacity(0.2))
                
                // Use this appearance when scrolling behind the TabView:
                UITabBar.appearance().standardAppearance = appearance
                // Use this appearance when scrolled all the way up:
                UITabBar.appearance().scrollEdgeAppearance = appearance
        }

        .animation(.easeOut, value: offSet == 0)
        .onChange(of: showMenu) { newValue in
            
            // Preview issues...
            
            if showMenu && offSet == 0{
                offSet = sideBarWidth
                lastStoredOffset = offSet
            }
            
            if !showMenu && offSet == sideBarWidth{
                offSet = 0
                lastStoredOffset = 0
            }
        }
        .onChange(of: gestureOffset) { newValue in
            onChange()
        }
    }
    
    func onChange(){
        withAnimation(.linear) {
            let sideBarWidth = getRect().width - 90
            offSet = (gestureOffset != 0) ? ((gestureOffset + lastStoredOffset) < sideBarWidth ? (gestureOffset + lastStoredOffset) : offSet) : offSet
            
            offSet = (gestureOffset + lastStoredOffset) > 0 ? offSet : 0
        }
        
    }
    
    func onEnd(value: DragGesture.Value){
        if value.velocity.width > 500 {
            swipeWithSpeed(value: value)
        
        }
        
        if value.velocity.width < -500 {
            swipeWithSpeed(value: value)
        }else {
            swipeAction(value: value)
        }
    }
    
    
    func swipeWithSpeed(value: DragGesture.Value){
        print(value.velocity.width)
        let sideBarWidth = getRect().width - 90

        let translation = value.translation.width

        withAnimation{
            // Checking...
            if translation > 0{
                    // Extra cases...
                    if offSet == sideBarWidth || showMenu{
                        return
                    }
                offSet = sideBarWidth
                showMenu = true
            }
            else{
                    if offSet == 0 || !showMenu{
                        return
                    }

                offSet = 0
                showMenu = false
            }
        }

        // storing last offset...
        lastStoredOffset = offSet
    }
    func swipeAction(value: DragGesture.Value) {
        let sideBarWidth = getRect().width - 90

        let translation = value.translation.width

        withAnimation{
            // Checking...
            if translation > 0{

                if translation > (sideBarWidth / 5){
                    // showing menu...
                    offSet = sideBarWidth
                    showMenu = true
                }
                else{

                    // Extra cases...
                    if offSet == sideBarWidth || showMenu{
                        return
                    }
                    offSet = 0
                    showMenu = false
                }
            }
            else{

                if -translation > (sideBarWidth / 5){
                    offSet = 0
                    showMenu = false
                }
                else{

                    if offSet == 0 || !showMenu{
                        return
                    }

                    offSet = sideBarWidth
                    showMenu = true
                }
            }
        }

        // storing last offset...
        lastStoredOffset = offSet
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}

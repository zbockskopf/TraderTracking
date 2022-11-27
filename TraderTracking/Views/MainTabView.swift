//
//  MainTabView.swift
//  TraderTracking
//
//  Created by Zach on 9/16/22.
//

import SwiftUI

struct MainTabView: View {

    @StateObject var realmController = RealmController()
	@StateObject var menuController = MenuController()
    @StateObject  var gestureController = GestureController()
    
    @EnvironmentObject var notifications: Notifications
	
    @StateObject var tradeListData = TradeListViewModel()
    @State private var selection = 0
    @State var showMenu: Bool = false
    @State var offSet: CGFloat = 0
    @State var lastStoredOffset: CGFloat = 0
    @State var showListView: Bool = false
    var screenWidth = UIScreen.main.bounds.width
    @Environment(\.colorScheme) var scheme
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
                            
                        
                        TradesListView()
                            .tabItem {
                                selection == 1 ? Image("List-Active") : Image("List-Inactive")
                                Text("")
                            }
                            .environmentObject(realmController)
                            .environmentObject(tradeListData)
                            .environmentObject(menuController)
                            .tag(1)
                        
//                        WebView(url: URL(string: "https://www.forexfactory.com")!)
//                            .tabItem {
//                                Image(systemName: "calendar")
//                            }
//                            .tag(2)
                        
                    }
                    .frame(width: getRect() .width)
                    .onChange(of: selection) { val in
                        if val == 1{
                            showListView = true
                        }else{
                            showListView = false
                        }
                    }
                }
            }
            .frame(width: getRect().width + sideBarWidth)
            .offset(x: -sideBarWidth / 2)
            .offset(x: offSet > 0 ? offSet : 0)
            .gesture( !showListView ?

                    DragGesture()
                        .updating($gestureOffset, body: { value, out, _ in
                            out = value.translation.width
                            
                        })
                        .onEnded(onEnd(value:))
                      : nil
            )
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
        .onAppear {
            if selection == 1{
                showListView = true
            }
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
        let sideBarWidth = getRect().width - 90
        
        let translation = value.translation.width
        
        withAnimation{
            // Checking...
            if translation > 0{
                
                if translation > (sideBarWidth / 2){
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
                
                if -translation > (sideBarWidth / 2){
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

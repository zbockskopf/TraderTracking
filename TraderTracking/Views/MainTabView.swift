//
//  MainTabView.swift
//  TraderTracking
//
//  Created by Zach on 9/16/22.
//

import SwiftUI

struct MainTabView: View {

    var realmController = RealmController()
    @StateObject var tradeListData = TradeListViewModel()
    @State private var selection = 0

    @State private var imageIsShown: Bool = false
    var screenWidth = UIScreen.main.bounds.width
    @State var showMenu: Bool  = false
    
    init() {
        UITabBar.appearance().isHidden = true
    }
     
    @State var currentTab = "Tracker-Active"
    @State var offset: CGFloat = 0
    @State var lastStoredOffset: CGFloat = 0
    @GestureState var gestureOffset: CGFloat = 0
    


    var body: some View {
        
        let sideBarWidth = getRect().width - 90
        
        NavigationView{
                                
            HStack(spacing: 0){
                
                SideMenu(showMenu: $showMenu)
                    .environmentObject(realmController)

                VStack(spacing: 0){
                    TabView(selection: $currentTab) {
                        ContentView(showMenu: $showMenu)
                            .environmentObject(realmController)
                            .tag("Tracker-Active")
                        TradesListView(imageIsShown: $imageIsShown)
                            .environmentObject(realmController)
                            .environmentObject(tradeListData)
                            .tag("List-Active")
                    }
                    VStack(spacing: 0){
                            Divider()
                            HStack(spacing: 0){
                                TabButton(image: "Tracker-Active")
                                TabButton(image: "List-Active")
                            }
                            .padding([.top], 15)
                        }
                    .frame(width: getRect().width)
                }
                .frame(width: getRect().width)
                .overlay(
                    Rectangle()
                        .fill(
                            Color.primary
                                .opacity(Double((offset / sideBarWidth) / 5))
                                
                        )
                        .ignoresSafeArea(.container, edges: .vertical)
                        .onTapGesture {
                            withAnimation {
                                showMenu.toggle()
                            }
                        }
                )
                
            }
            .frame(width: getRect().width + sideBarWidth)
            .offset(x: -sideBarWidth / 2)
            .offset(x: offset > 0 ? offset : 0)
            .gesture(
                DragGesture()
                    .updating($gestureOffset, body: { value, out, _ in
                        out = value.translation.width
                    })
                    .onEnded(onEnd(value:))
            )
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            
        }
        .animation(.easeOut, value: offset == 0)
        .onChange(of: showMenu) { newValue in
            if showMenu && offset == 0 {
                offset = sideBarWidth
                lastStoredOffset = offset
            }
            
            if !showMenu && offset == sideBarWidth {
                offset = 0
                lastStoredOffset = 0
            }
        }
        .onChange(of: gestureOffset) { newVaule in
            onChange()
        }
    }
    
    
    func onChange() {
        let sideBarWidth = getRect().width - 90
        offset = (gestureOffset != 0) ? (gestureOffset + lastStoredOffset < sideBarWidth ? gestureOffset + lastStoredOffset : offset) : offset
    }
    
    func onEnd(value: DragGesture.Value) {
        let sideBarWidth = getRect().width - 90
        
        let translation = value.translation.width
        
        if translation > 0 {
            if translation > (sideBarWidth / 2){
                offset = sideBarWidth
                showMenu = true
            }else{
                if offset == sideBarWidth {
                    return
                }
                offset = 0
                showMenu = false
            }
        }else{
            if -translation > (sideBarWidth / 2){
                offset = 0
                showMenu = false
            }else{
                if offset == 0 || !showMenu{
                    return
                }
                offset = sideBarWidth
                showMenu = true
            }
        }
        
        lastStoredOffset = offset
    }
    
    @ViewBuilder
    func TabButton(image: String)-> some View {
        
        Button {
            withAnimation {
                currentTab = image
            }
        } label: {
            Image(image)
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .frame(width: 28, height: 27)
                .foregroundColor(currentTab == image ? .green : .gray)
                .frame(maxWidth: .infinity)
        }
        
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}

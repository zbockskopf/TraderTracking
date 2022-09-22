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
    @State var xOffset: CGFloat = 0
    @State var currentXOffset: CGFloat = 0
    @Environment(\.colorScheme) var scheme

    var body: some View {
        GeometryReader { reader in
            HStack(spacing: 0){
                SideMenu(currentXOffset: $currentXOffset, xOffset: $xOffset)
                    .frame(width: screenWidth * 0.8)

                ZStack{
                    TabView(selection: $selection) {
                        ContentView(currentXOffset: $currentXOffset, xOffset: $xOffset)
                            .tabItem {
                                selection == 0 ? Image("Tracker-Active") : Image("Tracker-Inactive")
                                Text("")
                            }
                            
                            .environmentObject(realmController)
                            .tag(0)
                        TradesListView(imageIsShown: $imageIsShown)
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

//                    (scheme == .light ? Color.black : Color.white).opacity(0.3)
//                        .opacity(xOffset == 0 ? 0.7 : 0)
//                        .ignoresSafeArea()
                }
//                .overlay(
//                    ZStack{
//                        if imageIsShown{
//                            NavigationView{
//                                ImageUIView(isPresented: $imageIsShown)
//                                    .environmentObject(tradeListData)
//                                    .navigationBarItems(
//                                        leading:
//                                            Button(action: {
//                                                print("test")
//                                                if let topController = UIApplication.topViewController() {
//                                                topController.dismiss(animated: true)
//                                            }
//                                            }, label: {
//                                                if currentXOffset != 0.0 {
//                                                    Image("Profile")
//                                                        .resizable()
//                                                        .scaledToFit()
//                                                        .frame(width: 40, height: 40)
//                                                        .clipShape(Circle())
//                                                }
//                                            })
//                                    )
//                            }
//                        }
//                    }
//                )
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

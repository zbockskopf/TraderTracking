//
//  ContentView.swift
//  TraderTracking
//
//  Created by Zach on 9/15/22.
//

import SwiftUI
import SwiftPieChart
import RealmSwift
import ConfettiSwiftUI

struct ContentView: View {

    @EnvironmentObject var realmController: RealmController
    @EnvironmentObject var notifications: Notifications
    @EnvironmentObject var menuController: MenuController


    @State private var confettiCounter: Int = 0
    @State private var showNewTrade = false
    @State private var sheetAction: SheetAction? = SheetAction.nothing
    @Binding var showMenu: Bool
    @Binding var offSet: CGFloat

    var screenWidth = UIScreen.main.bounds.width
    	
    @Environment(\.colorScheme) var scheme

    var body: some View {

        NavigationStack{
//            HStack {
//                Text("Monthly")
//                    .frame(alignment: .leading)
//            }
//            .frame(maxWidth: .infinity, alignment: .topLeading)
//            .padding()
            ZStack{
                VStack{
                    Text(realmController.winRate)
                        .font(.largeTitle)
                        .padding()
                    
                    HStack{
                        Spacer()
                        
                        VStack{
                            Text("Wins")
                            Text(String(realmController.wins.count))
                        }
                        .foregroundColor(Color(UIColor.label))
                        
                        Spacer()
                        
                        VStack{
                            Text("Losses")
                            Text(String(realmController.losses.count))
                        }
                        .foregroundColor(Color(UIColor.label))
                        
                        Spacer()
                    }
                    .padding()
                    
                    
                    
                    VStack{
                        Button(action: {
//                            confettiCounter += 1
                            showNewTrade.toggle()
                        }) {
                            Text("New Trade")
                                .frame(minWidth: 0, maxWidth: 200)
                                .font(.system(size: 18))
                                .padding()
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.green, lineWidth: 2)
                                )
                        }
                        .background(Color.green)
                        .cornerRadius(25)
                        .confettiCannon(counter: $confettiCounter, num: 250, confettis: [.shape(.slimRectangle), .shape(.square)], colors: [.green], rainHeight: 700, openingAngle: Angle.degrees(35), closingAngle: Angle.degrees(145), radius: 400)
                        .sheet(isPresented: $showNewTrade, onDismiss: {
                            delayConfetti(sheetAction: sheetAction!, realmController: realmController)
                        }){
                            NewTradeView(sheetAction: $sheetAction, isEditing: false)
                                .environmentObject(realmController)
                        }
                        
                    }
                    .padding()
                }
                (scheme == .light ? Color.black : Color.white).opacity(0.3)
                    .opacity(offSet > 0 ? ((offSet+90)/screenWidth) : 0)
                    .ignoresSafeArea()
                    .allowsHitTesting(offSet > 0 ? true : false)
                    .onTapGesture {
                        withAnimation {
                            showMenu.toggle()
                        }
                    }
                //                NavigationLink(value: "showNotificationSettings") {
                //                    Text("")
                //                }
                //                .hidden()
                //                NavigationLink(destination: NotificationSettings(), isActive: $showNotificationSettings) {
                //
                //                }
                //                .hidden()
            }
            .navigationDestination(isPresented: $menuController.showNotificationSettings, destination: {
                NotificationSettings()
                    .navigationBarTitle("Notifications")
                    .environmentObject(notifications)
            })
            .navigationDestination(isPresented: $menuController.showProfile, destination: {
                ProfileView()
            })
            .navigationDestination(isPresented: $menuController.showSettings, destination: {
                Settings()
                    .environmentObject(menuController)
                    .environmentObject(realmController)
            })
            .navigationBarTitle("")
            .navigationBarItems(
                leading:
                    Button(action: {
                        withAnimation{
                            showMenu.toggle()
                        }
                    }, label: {
//                        withAnimation(.fade,{
                            if offSet + 90 > 0{
                                Image("Profile")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            }
//                        })
                        
                    })
                , trailing:
                    Button {
                        menuController.showProfile.toggle()
                        
                    } label: {
                        Image(systemName: "chart.bar.fill")
                        
                    }
                    .foregroundColor(.green)
                    
                    
            )

        }
        .frame(
              minWidth: 0,
              maxWidth: .infinity,
              minHeight: 0,
              maxHeight: .infinity
            )

    }


    private func delayConfetti(sheetAction: SheetAction, realmController: RealmController) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//          add swtich here for sheetAction
            switch sheetAction {
            case .nothing, .loss, .cancel:
                break
            case .win:
                confettiCounter += 1
            case .done:
                break
            }
            self.sheetAction = .nothing
        }
    }

}

enum SheetAction {
    case nothing
    case loss
    case win
    case cancel
    case done
}


struct SmallProfileView: View {
    var body: some View {
        Image("Profile")
            .resizable()
            .scaledToFit()
            .frame(width: 55, height: 55)
            .clipShape(Circle())
    }
}

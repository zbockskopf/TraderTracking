//
//  SideMenu.swift
//  TraderTracking
//
//  Created by Zach on 9/16/22.
//

import SwiftUI

struct SideMenu: View {
    @EnvironmentObject var realmController: RealmController
    @EnvironmentObject var notifications: Notifications
	@EnvironmentObject var menuController: MenuController
    @Binding var showMenu: Bool
    var screenWidth = UIScreen.main.bounds.width

    
    var body: some View {
        ZStack{
            VStack(alignment: .leading) {
                
                HStack(alignment: .top) {
                    Button(action: {
                        withAnimation{
//                            xOffset = -screenWidth * 0.8
                            showMenu.toggle()
                            menuController.showProfile.toggle()
                        }
                    }, label: {
                            Image("Profile")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 55, height: 55)
                                .clipShape(Circle())
                    })

                    Spacer()
                }
                Divider()
                VStack(alignment: .listRowSeparatorLeading){

                    ForexCalendarButton(showForexCalendar: $notifications.showForexCalendar)
                    NotificationButton(showNotificationSettings: $menuController.showNotificationSettings)
//					SettingButton(showSettings: $menuController.showSettings)
                    

                }
                .fixedSize()
                Spacer()
                HStack{
                    Button {
                        withAnimation{
//                            xOffset = -screenWidth * 0.8
                            showMenu.toggle()
                            menuController.showSettings.toggle()
                        }
                    } label: {
                        Image(systemName: "gear")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                }
                .padding()
                .frame(height: 40, alignment: .leading)
            }
            .padding(.horizontal)
            
        }
        .frame(
              minWidth: 0,
              maxWidth: .infinity,
              minHeight: 0,
              maxHeight: .infinity,
              alignment: .topLeading
        )
        .background(Color(UIColor.systemBackground))
//        .gesture(
//            DragGesture()
//                .onChanged({ value in
//                    if value.startLocation.x < CGFloat(100.0){
//                        if value.translation.width > 0 && xOffset != 0 { // left to right
//                            withAnimation {
//                                xOffset = currentXOffset + value.translation.width
//                            }
//                        } else if value.translation.width < 0 && xOffset != -screenWidth * 0.8 {
//                            withAnimation {
//                                xOffset = currentXOffset + value.translation.width
//                            }
//                        }
//                    }
//                })
//                .onEnded({ value in
//                    if value.translation.width > 0 { // left to right
//                        withAnimation {
//                            xOffset = 0
//                        }
//                    } else {
//                        withAnimation {
//                            xOffset = -screenWidth * 0.8
//                        }
//                    }
//                    currentXOffset = xOffset
//                })
//        )
    }
    
}

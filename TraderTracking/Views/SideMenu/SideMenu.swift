//
//  SideMenu.swift
//  TraderTracking
//
//  Created by Zach on 9/16/22.
//

import SwiftUI

struct SideMenu: View {
    @EnvironmentObject var realmController: RealmController
    @EnvironmentObject var notifications: MyNotifications
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
                        if UserDefaults.standard.bool(forKey: "personalDevice"){
                            Image("Profile")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())

                        }else{
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                                .foregroundColor(.green)
                        }
                    })

                    Spacer()
                }
                Divider()
                SideMenuStats()
                    .environmentObject(realmController)
                Divider()
                VStack(alignment: .listRowSeparatorLeading){
                    ForexCalendarButton(showForexCalendar: $notifications.showForexCalendar)
                    NotificationButton(showNotificationSettings: $menuController.showNotificationSettings, showMenu: $showMenu)
                    if UserDefaults.standard.bool(forKey: "personalDevice"){
                        ModelsButon(showModelSettings: $menuController.showModelSettigs, showMenu: $showMenu)
                        DailyReviewButton(showDailyReview: $menuController.showDailyReview, showMenu: $showMenu)
                    }
                }
                .environmentObject(menuController)
                .fixedSize()
                Spacer()
                Divider()
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
    }
    
}

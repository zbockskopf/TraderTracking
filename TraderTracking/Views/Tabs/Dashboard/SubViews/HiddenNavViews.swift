//
//  HiddenNavViews.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 4/21/23.
//

import SwiftUI

struct HiddenNavigationView: View {
    @EnvironmentObject var menuController: MenuController
    @EnvironmentObject var notifications: MyNotifications
    @EnvironmentObject var realmController: RealmController
    
    var body: some View {
        VStack {
            NavigationLink("", destination: NotificationSettings()
                .navigationBarTitle("Notifications")
                .environmentObject(notifications), isActive: $menuController.showNotificationSettings)
            
            NavigationLink("", destination: ProfileView(), isActive: $menuController.showProfile)
            
            NavigationLink("", destination: AccountPager()
                .environmentObject(menuController)
                .environmentObject(realmController), isActive: $menuController.showAccout)
            
            NavigationLink("", destination: Settings()
                .environmentObject(menuController)
                .environmentObject(realmController), isActive: $menuController.showSettings)
            
            NavigationLink("", destination: ModelsListView(realm: realmController.realm)
                .environmentObject(menuController)
                .environmentObject(realmController), isActive: $menuController.showModelSettigs)
            
//            NavigationLink("", destination: ReviewView(), isActive: $menuController.showDailyReview)
        }
        .frame(width: 0, height: 0)
        .opacity(0)
    }
}

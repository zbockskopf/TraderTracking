//
//  TraderTrackingApp.swift
//  TraderTracking
//
//  Created by Zach on 9/15/22.
//

import SwiftUI

@main
struct TraderTrackingApp: App {
    @Environment(\.scenePhase) var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State var currentXOffset: CGFloat = 0
    @State var xOffset: CGFloat = 0
    @StateObject var realmController = RealmController()
    var notifications: Notifications?
//    var f = ForexCrawler()
    private var hasLaunched = UserDefaults.standard.bool(forKey: "launchedBefore")
    
    init() {
        
        
        if !hasLaunched {
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            UserDefaults.standard.set(Date(), forKey: "notificationTime")
            UserDefaults.standard.setValue(0, forKey: "defaultTab")
            realmController.setDefaults()
        }else{

        }
        notifications = Notifications()
        UNUserNotificationCenter.current().delegate = notifications
        }
    
    var body: some Scene {
        WindowGroup {
//            ContentView(currentXOffset: $currentXOffset, xOffset: $xOffset)
//                .environmentObject(realmController)
            MainTabView()
                .environmentObject(notifications!)
                .onChange(of: scenePhase) { newPhase in
                                    if newPhase == .background {
                                        UIApplication.shared.applicationIconBadgeNumber = 0
                                    }
                                }
        }
        
    }
}

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
    var realmController = RealmController()
    var body: some Scene {
        WindowGroup {
//            ContentView(currentXOffset: $currentXOffset, xOffset: $xOffset)
//                .environmentObject(realmController)
            MainTabView()
                .onChange(of: scenePhase) { newPhase in
                                    if newPhase == .background {
                                        UIApplication.shared.applicationIconBadgeNumber = 0
                                    }
                                }
        }
    }
}

//
//  AppDelegate.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 9/20/22.
//

import Foundation
import UIKit
import RealmSwift




class AppDelegate: NSObject, UIApplicationDelegate {
//    static var orientationLock = UIInterfaceOrientationMask.all

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        return true
    }
}




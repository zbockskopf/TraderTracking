//
//  AppDelegate.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 9/20/22.
//

import Foundation
import UIKit




class AppDelegate: NSObject, UIApplicationDelegate {
    var orientationLock = UIInterfaceOrientationMask.all

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
            return self.orientationLock
    }
}

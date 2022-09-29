//
//  Notifications.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 9/29/22.
//

import Foundation
import UserNotifications


class Notifications: ObservableObject {
    
    
    init(){
        requestAuthorization { _ in}
    }
    
    func requestAuthorization(completion: @escaping  (Bool) -> Void) {
      UNUserNotificationCenter.current()
        .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _  in
          // TODO: Fetch notification settings
          completion(granted)
        }
    }
    
    func forexCalendarReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Calendar"
        content.body = "Check Forex Calendar"
        content.badge = NSNumber(value: 1)
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current

        dateComponents.hour = 7    // 14:00 hours
        dateComponents.minute = 00
           
        // Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(
                 dateMatching: dateComponents, repeats: false)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                    content: content, trigger: trigger)

        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
           if error != nil {
              // Handle any errors.
           }
        }
    }
    
    func clearNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

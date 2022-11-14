//
//  Notifications.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 9/29/22.
//

import Foundation
import UserNotifications


class Notifications: NSObject, ObservableObject {
    
    
    @Published var showForexCalendar: Bool = false
    @Published var notificationTime = UserDefaults.standard.object(forKey: "notificationTime") as! Date{
        didSet{
            UserDefaults.standard.setValue(self.notificationTime, forKey: "notificationTime")
            forexCalendarReminder()
        }
    }
    
    
    override init(){
        super.init()
        requestAuthorization { _ in}
    }
    
    func toggleForexCalendar() {
        showForexCalendar.toggle()
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
        
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: notificationTime)
        let min = calendar.component(.minute, from: notificationTime)
        
        var dateComponents = DateComponents()
        dateComponents.calendar = calendar
        
        dateComponents.hour = hour    
        dateComponents.minute = min
           
        // Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(
                 dateMatching: dateComponents, repeats: true)
        
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

extension Notifications: UNUserNotificationCenterDelegate {


    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    didReceive response: UNNotificationResponse,
                                    withCompletionHandler completionHandler: @escaping () -> Void) {
        
        self.toggleForexCalendar()
        completionHandler()
        }
}

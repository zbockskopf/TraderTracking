//
//  Notifications.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 9/29/22.
//

import Foundation
import UserNotifications
import UIKit


class MyNotifications: NSObject, ObservableObject {
    
    
    @Published var showForexCalendar: Bool = false
    @Published var notificationTime = UserDefaults.standard.object(forKey: "notificationTime") as! Date{
        didSet{
            UserDefaults.standard.setValue(self.notificationTime, forKey: "notificationTime")
            forexCalendarReminder()
        }
    }
    
    @Published var notification240Time = UserDefaults.standard.object(forKey: "notification240Time") as! Date{
        didSet{
            UserDefaults.standard.setValue(self.notification240Time, forKey: "notification240Time")
            twoFortyMarco()
        }
    }
    
    @Published var tradingPlanTime = UserDefaults.standard.object(forKey: "tradingPlanTime") as! Date{
        didSet{
            UserDefaults.standard.setValue(self.notification240Time, forKey: "tradingPlanTime")
            tradingPlan()
        }
    }
    
    @Published var openingBellTime = UserDefaults.standard.object(forKey: "openingBellTime") as! Date{
        didSet{
            UserDefaults.standard.setValue(self.openingBellTime, forKey: "openingBellTime")
            openingBell()
        }
    }
    
    @Published var COTReleaseTime = UserDefaults.standard.object(forKey: "COTReleaseTime") as! Date{
        didSet{
            UserDefaults.standard.setValue(self.COTReleaseTime, forKey: "COTReleaseTime")
            COTRelease()
        }
    }
    
//    @Published var dailyNewsTime = UserDefaults.standard.object(forKey: "dailyNewsTime") as! Date{
//        didSet{
//            UserDefaults.standard.setValue(self.COTReleaseTime, forKey: "dailyNewsTime")
//            dailyNews()
//        }
//    }
    
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
    
    func dailyNews() {
        
    }
    
    func twoFortyMarco() {
        clear240Macro()
        let content = UNMutableNotificationContent()
        content.title = "Marco"
        content.body = "2:40 Marco"
        content.badge = NSNumber(value: 1)
        content.sound = .default
        
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: notification240Time)
        let min = calendar.component(.minute, from: notification240Time)
        let weekdays = [2,3,4,5,6]
        for i in weekdays {
            var dateComponents = DateComponents()
            dateComponents.calendar = calendar
            dateComponents.weekday = i
            dateComponents.hour = hour
            dateComponents.minute = min
               
            // Create the trigger as a repeating event.
            let trigger = UNCalendarNotificationTrigger(
                     dateMatching: dateComponents, repeats: true)
            
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: "240Macro" + String(i),
                        content: content, trigger: trigger)

            // Schedule the request with the system.
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
               if error != nil {
                  // Handle any errors.
               }
            }
        }
    }
    
    func forexCalendarReminder() {
        clearCalendarReminder()
        let content = UNMutableNotificationContent()
        content.title = "Calendar"
        content.body = "Check Forex Calendar"
        content.badge = NSNumber(value: 1)
        content.sound = .default
        
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: notificationTime)
        let min = calendar.component(.minute, from: notificationTime)
        let weekdays = [2,3,4,5,6]
        for i in weekdays {
            var dateComponents = DateComponents()
            dateComponents.calendar = calendar
            dateComponents.weekday = i
            dateComponents.hour = hour
            dateComponents.minute = min
               
            // Create the trigger as a repeating event.
            let trigger = UNCalendarNotificationTrigger(
                     dateMatching: dateComponents, repeats: true)
            
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: "calendarReminder" + String(i),
                        content: content, trigger: trigger)

            // Schedule the request with the system.
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
               if error != nil {
                  // Handle any errors.
               }
            }
        }
    }
    
    func tradingPlan() {
        clearTradingPlan()
        let content = UNMutableNotificationContent()
        content.title = "Trading Plan"
        content.body = "Review trading Plan"
        content.badge = NSNumber(value: 1)
        content.sound = .default
        
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: tradingPlanTime)
        let min = calendar.component(.minute, from: tradingPlanTime)
        let weekdays = [2,3,4,5,6]
        for i in weekdays {
            var dateComponents = DateComponents()
            dateComponents.calendar = calendar
            dateComponents.weekday = i
            dateComponents.hour = hour
            dateComponents.minute = min
               
            // Create the trigger as a repeating event.
            let trigger = UNCalendarNotificationTrigger(
                     dateMatching: dateComponents, repeats: true)
            
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: "tradingPlan" + String(i),
                        content: content, trigger: trigger)

            // Schedule the request with the system.
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
               if error != nil {
                  // Handle any errors.
               }
            }
        }
    }
    
    func COTRelease() {
        clearCOTRelease()
        let content = UNMutableNotificationContent()
        content.title = "COT Release"
        content.body = ""
        content.badge = NSNumber(value: 1)
//        content.sound = UNNotificationSound(named: UNNotificationSoundName("thinkorswim_bell.mp3"))
        
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: COTReleaseTime)
        let min = calendar.component(.minute, from: COTReleaseTime)
        let weekdays = [3]
        for i in weekdays {
            var dateComponents = DateComponents()
            dateComponents.calendar = calendar
            dateComponents.weekday = i
            dateComponents.hour = hour
            dateComponents.minute = min
               
            // Create the trigger as a repeating event.
            let trigger = UNCalendarNotificationTrigger(
                     dateMatching: dateComponents, repeats: true)
            
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: "COTReleaseTime" + String(i),
                        content: content, trigger: trigger)

            // Schedule the request with the system.
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
               if error != nil {
                  // Handle any errors.
               }
            }
        }
    }
    
    func openingBell() {
        clearOpeningBell()
        let content = UNMutableNotificationContent()
        content.title = "Opening Bell"
        content.body = "Have Patience Today!"
        content.badge = NSNumber(value: 1)
        content.sound = UNNotificationSound(named: UNNotificationSoundName("thinkorswim_bell.mp3"))
        
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: openingBellTime)
        let min = calendar.component(.minute, from: openingBellTime)
        let weekdays = [2,3,4,5,6]
        for i in weekdays {
            var dateComponents = DateComponents()
            dateComponents.calendar = calendar
            dateComponents.weekday = i
            dateComponents.hour = hour
            dateComponents.minute = min
               
            // Create the trigger as a repeating event.
            let trigger = UNCalendarNotificationTrigger(
                     dateMatching: dateComponents, repeats: true)
            
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: "openingBell" + String(i),
                        content: content, trigger: trigger)

            // Schedule the request with the system.
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
               if error != nil {
                  // Handle any errors.
               }
            }
        }
    }

       
    
    func clearNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    func clearCalendarReminder(){
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["calendarReminder2", "calendarReminder3", "calendarReminder4", "calendarReminder5", "calendarReminder6"])
    }
    
    func clear240Macro() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["240Macro2", "240Macro3", "240Macro4", "240Macro5","240Macro6"])
    }
    
    func clearTradingPlan() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["tradingPlan2", "tradingPlan3", "tradingPlan4", "tradingPlan5", "tradingPlan6"])
    }
    
    func clearOpeningBell() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["openingBell2", "openingBell3", "openingBell4", "openingBell5", "openingBell6"])
    }
    
    func clearCOTRelease() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["COTRelease2", "COTRelease3", "COTRelease4", "COTRelease5", "COTRelease6"])
    }
}

extension MyNotifications: UNUserNotificationCenterDelegate {


    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    didReceive response: UNNotificationResponse,
                                    withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier.contains("240Macro"){
            UIApplication.shared.open(URL(string: "tradingview://")!)
        }else if response.notification.request.identifier.contains("tradingPlan"){
            UIApplication.shared.open(URL(string: "https://www.notion.so/Plans-Setups-d081707bbfe643e3845a8fc4e430d916")!)
        }else if response.notification.request.identifier.contains("openingBell"){
            UIApplication.shared.open(URL(string: "tos://")!)
        }else{
            MenuController.shared.changeTab()
        }
        
        
        completionHandler()
        }
}

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

    @StateObject var realmController = RealmController()
    @StateObject var newsController: ForexCrawler = ForexCrawler()
    var notifications: MyNotifications?
    
    private var hasLaunched = UserDefaults.standard.bool(forKey: "launchedBefore")
    private var last = UserDefaults.standard.bool(forKey: "isNewDay")
    
    init() {
        if !hasLaunched {
            UserDefaults.standard.set(Date(), forKey: "notificationTime")
            UserDefaults.standard.set(Date(), forKey: "notification240Time")
            UserDefaults.standard.set(Date(), forKey: "tradingPlanTime")
            UserDefaults.standard.set(Date(), forKey: "openingBellTime")
            UserDefaults.standard.setValue(0, forKey: "defaultTab")
            UserDefaults.standard.set(Date(), forKey: "COTReleaseTime")
            UserDefaults.standard.set("Import", forKey: "currentTradeButtonFunction")
            
        }
        runIfNewDay()
//        UserDefaults.standard.set("Import", forKey: "currentTradeButtonFunction")
//        UserDefaults.standard.set(true, forKey: "personalDevice")
//        UserDefaults.standard.removeObject(forKey: "personalDevice")
        
        notifications = MyNotifications()
//        notifications.clearNotification()
//        UNUserNotificationCenter.current().delegate = notifications
        UINavigationBar.appearance().tintColor = UIColor.green // Change to your desired color

    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(notifications!)
                .environmentObject(realmController)
                .environmentObject(newsController)
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .background || newPhase == .active {
                        UIApplication.shared.applicationIconBadgeNumber = 0
                        updateNews()
                    }
                }
        }
    }
    
    func isNewDay() -> Bool {
        let calendar = Calendar.current
        let lastRunDate = UserDefaults.standard.object(forKey: "lastRunDate") as? Date ?? Date.distantPast

        return !calendar.isDateInToday(lastRunDate)
    }
    func saveLastRunDate() {
        let currentDate = Date()
        UserDefaults.standard.set(currentDate, forKey: "lastRunDate")
    }
    
    func runIfNewDay() {
        if isNewDay() {
//            realmController.updateAccountDailyBalance()
            saveLastRunDate()
        }
    }
    
    func updateNews() {
        let group = DispatchGroup()
        group.enter()
//        print(Date().startOfTheWeek)
//        newsController.tradingDayNews(date: MyFormatter().forexCalendarFormat(date: Date().startOfTheWeek))
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .failure(let error):
//                    print("An error occurred: \(error)")
//                case .finished:
//                    print("Finished fetching news")
//                }
//            }, receiveValue: { news in
//                newsController.dailyNews = news
//            })
//            .store(in: &newsController.cancellables)
//        newsController.tradingDayNews(date: MyFormatter().forexCalendarFormat(date: Date().newsNextWeekDates[0]))
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .failure(let error):
//                    print("An error occurred: \(error)")
//                case .finished:
//                    print("Finished fetching news")
//                }
//            }, receiveValue: { news in
//                newsController.nextWeekNews = news
//                group.leave()
//            })
//            .store(in: &newsController.cancellables)
        
        newsController.tradingDayNews(date: MyFormatter().forexCalendarFormat(date: Date().startOfTheWeek)) { n in
//            print(n)
            DispatchQueue.main.async {
                newsController.dailyNews = n
            }
        }
        
        newsController.tradingDayNews(date: MyFormatter().forexCalendarFormat(date: Date().newsNextWeekDates[0])) { n in
//            print(Date().newsNextWeekDates[0])
//            print(n)
            DispatchQueue.main.async {
                newsController.nextWeekNews = n
            }
            group.leave()
        }
        group.wait()
    }
}

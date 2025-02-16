//
//  TraderTrackingApp.swift
//  TraderTracking
//
//  Created by Zach on 9/15/22.
//
import Foundation
import SwiftUI


@main
struct TraderTrackingApp: App {
    @Environment(\.scenePhase) var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject var realmController = RealmController()
    @StateObject var newsController: ForexCrawler = ForexCrawler()
    var discordBot: DiscordBot?
    
    @State private var isFetchingData = false
    var notifications: MyNotifications?
    
    private var hasLaunched = UserDefaults.standard.bool(forKey: "launchedBefore")
    private var last = UserDefaults.standard.bool(forKey: "isNewDay")
    
    init() {
//        UserDefaults.standard.set(true, forKey: "personalDevice")
        if !hasLaunched {
            // Set UserDefaults
            UserDefaults.standard.set(Date(), forKey: "notificationTime")
            UserDefaults.standard.set(Date(), forKey: "notification240Time")
            UserDefaults.standard.set(Date(), forKey: "tradingPlanTime")
            UserDefaults.standard.set(Date(), forKey: "openingBellTime")
            UserDefaults.standard.setValue(0, forKey: "defaultTab")
            UserDefaults.standard.set(Date(), forKey: "COTReleaseTime")
            UserDefaults.standard.set("Import", forKey: "currentTradeButtonFunction")

            // Discord refresh
            let calendar = Calendar.current
            var components = DateComponents()
            components.year = 2015
            components.month = 5
            components.day = 13

            if let discordReleaseDate = calendar.date(from: components) {
                UserDefaults.standard.set(discordReleaseDate, forKey: "discordLastTradeFetched")
                UserDefaults.standard.set(discordReleaseDate, forKey: "discordLastForecastFetched")
                UserDefaults.standard.set(discordReleaseDate, forKey: "discordLastReviewFetched")
            }

            //Setup default Journal Directories
            _ = createDirectory(named: "Journal/Trades")
            _ = createDirectory(named: "Journal/Forecast")
            _ = createDirectory(named: "Journal/Reviews")

        }
        
        if UserDefaults.standard.bool(forKey: "personalDevice"){
            discordBot = DiscordBot()
        }

        runIfNewDay()
        
        notifications = MyNotifications()

        UINavigationBar.appearance().tintColor = UIColor.green // Change to your desired color

    }
    
    var body: some Scene {
        WindowGroup {
            ZStack{
                MainTabView()
                    .environmentObject(notifications!)
                    .environmentObject(realmController)
                    .environmentObject(newsController)
                    .onChange(of: scenePhase) { newPhase in
                        if newPhase == .background || newPhase == .active {
                            UIApplication.shared.applicationIconBadgeNumber = 0
                            updateNews()
//                            toggleFetching(true)  // Show loading
                            if UserDefaults.standard.bool(forKey: "personalDevice"){
                                discordBot!.updateTradesJournal {
                                    //                                toggleFetching(false)  // Hide loading when done
                                }
                                discordBot!.updateForecastJournal {
                                    //                                toggleFetching(false)
                                }
                                discordBot!.updateReviewJournal {
//                                    toggleFetching(false)
                                }
                            }
                        }
                    }
                if isFetchingData {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    ProgressView("Fetching Data...")
                        .scaleEffect(1.5)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
            }
        }
    }
    
    func toggleFetching(_ isFetching: Bool) {
        DispatchQueue.main.async {
            self.isFetchingData = isFetching
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
    
    func createDirectory(named directoryName: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Could not find documents directory.")
            return nil
        }
        
        let directoryURL = documentsDirectory.appendingPathComponent(directoryName)
        
        if !fileManager.fileExists(atPath: directoryURL.path) {
            do {
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
                print("Directory created at \(directoryURL)")
            } catch {
                print("Error creating directory: \(error)")
                return nil
            }
        }
        
        return directoryURL
    }
}

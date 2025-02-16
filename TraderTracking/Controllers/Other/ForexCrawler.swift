//
//  ForexCrawler.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 11/12/22.
//

import Foundation
import SwiftSoup
import SwiftUI
import Combine



class ForexCrawler: NSObject, ObservableObject {
    
    var document: Document = Document.init("")
    
    static let shared = ForexCrawler()
    @Published var dailyNews: [News] = []
    @Published var nextWeekNews: [News] = []
    let myFormatter = MyFormatter()
    
    
    @Published var showHighImpact: Bool = UserDefaults.standard.bool(forKey: "showHighImpact") {
        didSet{
            UserDefaults.standard.set(self.showHighImpact, forKey: "showHighImpact")
        }
    }
    
    @Published var showMediumImpact: Bool = UserDefaults.standard.bool(forKey: "showMediumImpact") {
        didSet{
            UserDefaults.standard.set(self.showMediumImpact, forKey: "showMediumImpact")
        }
    }
    
    @Published var showLowImpact: Bool = UserDefaults.standard.bool(forKey: "showLowImpact") {
        didSet{
            UserDefaults.standard.set(self.showLowImpact, forKey: "showLowImpact")
        }
    }
    //AUD, CAD, CHF, CNY, EUR, GBP, JPY, NZD,USD
    @Published var newsCurrenciesFilter: [String: Bool] = {
        if let filter = UserDefaults.standard.dictionary(forKey: "newsCurrenciesFilter") as? [String: Bool] {
            return filter
        } else {
            return ["AUD": false, "CAD": false, "CHF": false, "CNY": false, "EUR": false, "GBP": false, "JPY": false,"NZD": false, "USD": true]
        }
    }() {
        didSet {
            UserDefaults.standard.set(self.newsCurrenciesFilter, forKey: "newsCurrenciesFilter")
        }
    }
    func tradingDayNews(date: String, completion: @escaping ([News]) -> ()) {
        var tempDailyNews: [News] = []
        let urlString = "https://www.forexfactory.com/calendar?week=" + date
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil, let html = String(data: data, encoding: .ascii) else {
                print(error ?? "Error fetching data")
                return
            }
            
            do {
                let document = try SwiftSoup.parse(html)
                let tableBody = try document.getElementsByClass("calendar__table").first()?.children().last()
//                print(tableBody)
                var time: String = ""
                var date: String = ""
                
                tableBody?.children().forEach { row in
                    do {
                       
                        if try row.className().contains("calendar__row--new-day") {
                            date = try row.child(0).text()
                            print(date)
                            time = ""
                            //                            if try row.className().contains("calendar__row--grey"){
                            //                                let news = News()
                            //
                            //                                let timeText = try row.child(1).text()
                            //                                news.time = timeText.isEmpty ? time : timeText
                            //                                time = news.time
                            //                                if try row.child(3).text() == "USD" || row.child(3).text() == "EUR" {
                            //                                    news.currecny = try row.child(3).text()
                            //                                    news.name = try row.child(5).text()
                            //                                    date.insert(" ", at: date.index(date.startIndex, offsetBy: 3))
                            //
                            //                                    if !["All Day", "Tentative", ""].contains(news.time) {
                            //                                        news.date = self.myFormatter.newsDate(date: "\(date) \(Date().currentYear) \(news.time)")
                            //                                    }
                            //                                    news.impact = self.getImpact(from: try row.child(4).child(0).className())
                            //                                    if tempDailyNews.last?.time == time && tempDailyNews.last?.date == news.date {
                            //                                        news.isSameTime = tempDailyNews.last?.time == time
                            //                                    }else{
                            //                                        news.isSameTime = false
                            //                                    }
                            //
                            //                                    tempDailyNews.append(news)
                            //                                }
                            //                            }
                        //}else if try row.className().contains("calendar__row calendar__row--no-event calendar__row--new-day"){
                        }else{
//                            print(row.hasAttr("data-event-id"), try row.text())
                            
                            if row.hasAttr("data-event-id"){
                            let news = News()
                            
                            let timeText = try row.children().first(where: { try $0.className().contains("time")})!.text()
                            news.time = timeText.isEmpty ? time : timeText
                            time = news.time
                                //print(try row.child(3), try row.child(3).text())
                            let currency = try row.children().first(where: { try $0.className().contains("currency")})?.text()
//                                print(currency)
                            if currency == "USD" || currency == "EUR" || currency == "CAD"{
                                news.currecny = try row.children().first(where: { try $0.className().contains("currency")})!.text()
                                news.name = try row.children().first(where: { try $0.className().contains("event")})!.text()
                                date.insert(" ", at: date.index(date.startIndex, offsetBy: 3))
//                                print(news.name)
                                if !["All Day", "Tentative", ""].contains(news.time) {
                                    news.date = self.myFormatter.newsDate(date: "\(date) \(Date().currentYear) \(news.time)")
                                }//else if news.time == "All Day"{
//                                    news.date = self.myFormatter.newsDate(date: date)
//                                }
                                news.impact = self.getImpact(from: try row.children().first(where: { try $0.className().contains("impact")})!.child(0).className())
                                if tempDailyNews.last?.time == time && tempDailyNews.last?.date == news.date {
                                    news.isSameTime = tempDailyNews.last?.time == time
                                }else{
                                    news.isSameTime = false
                                }
                                
                                tempDailyNews.append(news)
                            }else if currency == "All"{
                                
                            }
                        }
                        }
//                        if try row.className().contains("calendar__row calendar__row--new-day") {
//                            date = try row.child(0).text()
//                            time = ""
//                            if try row.className().contains("calendar__row"){
//                                let news = News()
//                                
//                                let timeText = try row.child(1).text()
//                                news.time = timeText.isEmpty ? time : timeText
//                                time = news.time
//                                if try row.child(3).text() == "USD" || row.child(3).text() == "EUR" {
//                                    news.currecny = try row.child(3).text()
//                                    news.name = try row.child(5).text()
//                                    date.insert(" ", at: date.index(date.startIndex, offsetBy: 3))
//                                    
//                                    if !["All Day", "Tentative", ""].contains(news.time) {
//                                        news.date = self.myFormatter.newsDate(date: "\(date) \(Date().currentYear) \(news.time)")
//                                    }
//                                    news.impact = self.getImpact(from: try row.child(4).child(0).className())
//                                    if tempDailyNews.last?.time == time && tempDailyNews.last?.date == news.date {
//                                        news.isSameTime = tempDailyNews.last?.time == time
//                                    }else{
//                                        news.isSameTime = false
//                                    }
//                                    
//                                    tempDailyNews.append(news)
//                                }
//                            }
//                        }
                        
                        
                    } catch {
                        print("Error parsing row: \(error)")
                    }
                }
                completion(tempDailyNews)
            } catch {
                print("Error parsing HTML: \(error)")
            }
        }.resume()
    }

    private func getImpact(from className: String) -> NewsImpact {
        if className.contains("red") {
            return .high
        } else if className.contains("ora") {
            return .medium
        } else if className.contains("yel") {
            return .low
        } else {
            return .none
        }
    }

}


//class ForexCrawler: ObservableObject {
//    static let shared = ForexCrawler()
//    
//    // Additional property to store cancellable instances
//    var cancellables: Set<AnyCancellable> = []
//    
//    @Published var dailyNews: [News] = []
//    @Published var nextWeekNews: [News] = []
//    @Published var showHighImpact: Bool = UserDefaults.standard.bool(forKey: "showHighImpact") {
//        didSet {
//            UserDefaults.standard.set(self.showHighImpact, forKey: "showHighImpact")
//        }
//    }
//    
//    @Published var showMediumImpact: Bool = UserDefaults.standard.bool(forKey: "showMediumImpact") {
//        didSet {
//            UserDefaults.standard.set(self.showMediumImpact, forKey: "showMediumImpact")
//        }
//    }
//    
//    @Published var showLowImpact: Bool = UserDefaults.standard.bool(forKey: "showLowImpact") {
//        didSet {
//            UserDefaults.standard.set(self.showLowImpact, forKey: "showLowImpact")
//        }
//    }
//    
//    @Published var newsCurrenciesFilter: [String: Bool] = {
//        if let filter = UserDefaults.standard.dictionary(forKey: "newsCurrenciesFilter") as? [String: Bool] {
//            return filter
//        } else {
//            return ["AUD": false, "CAD": false, "CHF": false, "CNY": false, "EUR": false, "GBP": false, "JPY": false,"NZD": false, "USD": true]
//        }
//    }() {
//        didSet {
//            UserDefaults.standard.set(self.newsCurrenciesFilter, forKey: "newsCurrenciesFilter")
//        }
//    }
//    
//    private let myFormatter = MyFormatter()
//    
//    private func getImpact(from className: String) -> NewsImpact {
//        if className.contains("high") {
//            return .high
//        } else if className.contains("medium") {
//            return .medium
//        } else if className.contains("low") {
//            return .low
//        } else {
//            return .none
//        }
//    }
//    
//    func tradingDayNews(date: String) -> Future<[News], Error> {
//            return Future { promise in
//                let urlString = "https://www.forexfactory.com/calendar?week=" + date
//                
//                guard let url = URL(string: urlString) else {
//                    promise(.failure(ForexCrawlerError.invalidURL))
//                    return
//                }
//                
//                URLSession.shared.dataTaskPublisher(for: url)
//                    .tryMap { data, _ in
//                        guard let html = String(data: data, encoding: .ascii) else {
//                            throw ForexCrawlerError.invalidData
//                        }
//                        return html
//                    }
//                    .map { html -> Future<[News], Error> in
//                        return Future { promise in
//                            DispatchQueue.global(qos: .background).async {
//                                do {
//                                    let document = try SwiftSoup.parse(html)
//                                    let tableBody = try document.getElementsByClass("calendar__table").first()?.children().last()
//                                    var time: String = ""
//                                    var date: String = ""
//                                    var tempDailyNews: [News] = []
//                                    
//                                    tableBody?.children().forEach { row in
//                                        do {
//                                            if try row.className().contains("calendar__row calendar__row--day-breaker") {
//                                                date = try row.child(0).text()
//                                                time = ""
//                                            }
//                                            
//                                            if try row.className().contains("calendar__row calendar_row") {
//                                                var news = News()
//                                                
//                                                let timeText = try row.child(1).text()
//                                                news.time = timeText.isEmpty ? time : timeText
//                                                time = news.time
//                                                
//                                                if try row.child(3).text() == "USD" {
//                                                    news.currecny = try row.child(3).text()
//                                                    news.name = try row.child(5).text()
//                                                    date.insert(" ", at: date.index(date.startIndex, offsetBy: 3))
//                                                    
//                                                    if !["All Day", "Tentative", ""].contains(news.time) {
//                                                        news.date = self.myFormatter.newsDate(date: "\(date) \(Date().currentYear) \(news.time)")
//                                                    }
//                                                    
//                                                    news.impact = self.getImpact(from: try row.child(4).className())
//                                                    if tempDailyNews.last?.time == time && tempDailyNews.last?.date == news.date {
//                                                        news.isSameTime = tempDailyNews.last?.time == time
//                                                    } else {
//                                                        news.isSameTime = false
//                                                    }
//                                                    
//                                                    tempDailyNews.append(news)
//                                                }
//                                            }
//                                        } catch {
//                                            print("Error parsing row: \(error)")
//                                        }
//                                    }
//                                    promise(.success(tempDailyNews))
//                                } catch {
//                                    promise(.failure(ForexCrawlerError.parsingError))
//                                }
//                            }
//                        }
//                    }
//                    .switchToLatest()
//                    .receive(on: DispatchQueue.main)
//                    .sink(receiveCompletion: { completion in
//                        switch completion {
//                        case .failure(let error):
//                            promise(.failure(error))
//                        case .finished:
//                            break
//                        }
//                    }, receiveValue: { news in
//                        promise(.success(news))
//                    })
//                    .store(in: &self.cancellables)
//            }
//        }
//
//}

enum ForexCrawlerError: Error {
    case invalidURL
    case invalidData
    case parsingError
}

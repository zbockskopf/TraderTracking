//
//  ForexCrawler.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 11/12/22.
//

import Foundation
import SwiftSoup
import SwiftUI






class ForexCrawler: NSObject, ObservableObject {
    
    var document: Document = Document.init("")
    
//    static let shared = ForexCrawler()
    
    override init() {
        super.init()

    }
    
    func tradingDayNews(date: String, completion: @escaping ([News]) -> ()){
        // url string to URL
            // content of url
        
        var dailyNews: [News] = []
        var urlString = "https://www.forexfactory.com/calendar?day=" + date
        if let url = URL(string: urlString){
            URLSession.shared.dataTask(with: url) { d, r, e in
                do {
                    let html =  String(data: d!, encoding: .ascii)
                    // parse it into a Document
                    self.document = try SwiftSoup.parse(html!)
                    // parse css query
                    print(self.document)
                    var time: String = ""
                    print(try! self.document.getElementsByClass("calendar__row").count)
                    for i in try! self.document.getElementsByClass("calendar__row") {
                        if try! i.getElementsByClass("calendar__currency").text() == "USD"{
                            if ((try! i.getElementsByClass("calendar__impact-icon").first()!.child(0).attr("title").contains("High")) || (try! i.getElementsByClass("calendar__impact-icon").first()!.child(0).attr("title").contains("Low"))){
                                var impact: NewsImpact = .none
                                if try! i.getElementsByClass("calendar__impact-icon").first()!.child(0).attr("title").contains("High"){
                                    impact = .high
                                }else{
                                    impact = .medium
                                }
                                let n = News()
                                n.currecny = try! i.getElementsByClass("calendar__currency").text()
                                n.impact = impact
                                n.name = try! i.getElementsByClass("calendar__event").text()
                                if try! i.getElementsByClass("calendar__time").text() != "" {
                                    if try! i.getElementsByClass("calendar__time").text() != time {
                                        time = try! i.getElementsByClass("calendar__time").text()
                                        n.time = time
                                    }
                                }else{
                                    n.time = time
                                }
                                
                                n.id = date + n.name
                                n.date = Calendar.current.startOfDay(for: Date())
                                
                                if RealmController.shared.news.filter("id = %@", n.id).count == 0 {
                                    dailyNews.append(n)
                                }
                            }
                        }
                    }
                    completion(dailyNews)
                }catch let error{
                    print(error)
                }
                
            }.resume()
        }
    }
}

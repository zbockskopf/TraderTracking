//
//  DataBase.swift
//  TraderTracking
//
//  Created by Zach on 9/15/22.
//

import Foundation
import RealmSwift
import SwiftUI


class RealmController: NSObject, ObservableObject {

    @Published var winRate: String = ""
    @Published var numWins: String = ""
    @Published var numLosses: String = ""
    @Published var pAndL: String = ""
    @ObservedResults(Trade.self, filter: NSPredicate(format: "isDeleted = false"), sortDescriptor: SortDescriptor(keyPath: "dateEntered", ascending: false)) var allTrades
    @ObservedResults(Trade.self, filter: NSPredicate(format: "isDeleted = false AND isHindsight = true"), sortDescriptor: SortDescriptor(keyPath: "dateEntered", ascending: false)) var allHindsightTrades
    @ObservedResults(Trade.self, filter: NSPredicate(format: "isDeleted = false AND isHindsight = false"), sortDescriptor: SortDescriptor(keyPath: "dateEntered", ascending: false)) var allActualTrades
    @ObservedResults(Trade.self, filter: NSPredicate(format: "win = true AND isHindsight = false AND isDeleted = false")) var wins
    @ObservedResults(Trade.self, filter: NSPredicate(format: "loss = true AND isHindsight = false AND isDeleted = false")) var losses
    @ObservedResults(Trade.self, filter: NSPredicate(format: "dateEntered BETWEEN {%@, %@} AND isDeleted = false", Calendar.current.date(byAdding: .day, value: -7, to: Date())! as CVarArg, Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date())! as CVarArg), sortDescriptor: SortDescriptor(keyPath: "dateEntered", ascending: false)) var trades
    @ObservedResults(Account.self) var accounts
    @ObservedResults(Symbol.self) var symbols
    @ObservedResults(News.self) var news
    @ObservedResults(News.self, filter: NSPredicate(format: "date = %@", Calendar.current.startOfDay(for: Date()) as CVarArg)) var todayNews
//    @Published var trades: [Trade] = []
//    @Published var symbols: [Symbol] = []
    var realm: Realm!
    var myImage: MyImages!
    

    static let shared = RealmController()
    let myFormatter = MyFormatter()
//    var forex = ForexCrawler()
//    var realmQue =  DispatchQueue(label: "realm")
    
    override init() {
        super.init()
        let config = Realm.Configuration(schemaVersion: 4,
                                                 migrationBlock: { migration, oldSchemaVersion in

                                                    if (oldSchemaVersion <= 1){
                                                        migration.enumerateObjects(ofType: Trade.className()) { (old, new) in
                                                            new!["news"] = []
                                                        }
                                                    }
            
//            if (oldSchemaVersion <= 3){
//                migration.enumerateObjects(ofType: Trade.className()) { (old, new) in
//                    new!["date"] = []
//                }
//            }
                                                    
                                                 })
                
                Realm.Configuration.defaultConfiguration = config
        
//        realmQue.sync {
            realm = try! Realm()
            myImage = try! MyImages()

            getWinRate()
            getTradesPL()
//        }
        
        
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last)
    }

    func setDefaults() {
        let temp1 = Symbol()
        temp1.name = "MES"
        temp1.market = "Futures"
        temp1.tickValue = 1.25

        let temp2 = Symbol()
        temp2.name = "MNQ"
        temp2.market = "Futures"
        temp2.tickValue = 0.50
        
        let account = Account()
        account.name = "Main"
        account.balance = 3000.00

        try! realm.write{
            realm.add(temp1)
            realm.add(temp2)
            realm.add(account)
        }
    }

    func getTrades() -> [Trade] {
        var trades: [Trade] = []
        for i in realm.objects(Trade.self).distinct(by: ["_id"]){
            trades.append(i)
        }
        return trades
    }

    private func getSymbols() -> [Symbol] {

        var symbols: [Symbol] = []
        for i in realm.objects(Symbol.self).distinct(by: ["_id"]){
            symbols.append(i)
          }
        return symbols
    }


    func getWinRate() {
        let wins = Double(realm.objects(Trade.self).filter("win = true AND isHindsight = false AND isDeleted = false").count)
        let losses = Double(realm.objects(Trade.self).filter("loss = true AND isHindsight = false AND isDeleted = false").count)

        let percentFormatter            = NumberFormatter()
        percentFormatter.numberStyle    = NumberFormatter.Style.percent
        percentFormatter.minimumFractionDigits = 1
        percentFormatter.maximumFractionDigits = 2
        var temp: Double = Double((wins/(wins + losses)))
        numWins = String(Int(wins))
        numLosses = String(Int(losses))
        
        if wins == 0.0 && losses == 0.0 {
            winRate = "No Trades"
        }else{
            winRate = percentFormatter.string(for: temp)!
        }
        getTradesPL()
        
    }
    
    func getTradesPL() {
        var temp: Decimal128 = 0.0
        for i in trades {
            if !i.isHindsight{
                temp += i.p_l
                temp -= i.fees
            }
        }
        pAndL = myFormatter.numFormat(num: temp)
    }
    
    func getWeekHindSightPL() -> String {
        var temp: Decimal128 = 0.0
        for i in trades {
            if i.isHindsight{
                temp += i.p_l
                temp -= i.fees
            }
        }
        return myFormatter.numFormat(num: temp)
    }
    
    func addTrade(trade: Trade, images: [UIImage]?, edited: Bool){
        if edited {
            try! self.realm.write{ [self] in
//                realm.create(Trade.self, value: trade, update: .all)
                self.realm.add(trade, update: .all)
                
//                trade.news.append(objectsIn: news)
//                realm.create(Trade.self, value: trade, update: .all)
                if trade.photoDirectory != nil{
                    self.myImage.saveImages(directory: trade.photoDirectory!, images: images!)
                }
                if !trade.isHindsight{
                    let account = self.realm.object(ofType: Account.self, forPrimaryKey: "Main")
                    account!.trades.append(trade)
                    account!.profitAndLoss += trade.p_l
                    account!.balance += (trade.p_l - trade.fees)
                    account!.fees += trade.fees
                }
            }
        }else{
//            let group = DispatchGroup()
//            group.enter()
//            var tempNews: [News] = []
//            ForexCrawler.shared.tradingDayNews(date: "nov13.2022") { n in
////                    self.realmQue.sync {
//                    tempNews = n
////                    }
//                group.leave()
//            }
//            group.wait()
//            self.addNews(news: tempNews)
            try! self.realm.write{ [self] in
                
                self.realm.add(trade)
                print(self.realm.objects(News.self).filter("date = %@", Calendar.current.startOfDay(for: Date()) as CVarArg))
                trade.news.append(objectsIn: self.realm.objects(News.self).filter("date = %@", Calendar.current.startOfDay(for: Date()) as CVarArg))
                if trade.photoDirectory != nil{
                    self.myImage.saveImages(directory: trade.photoDirectory!, images: images!)
                }
                
                if !trade.isHindsight{
                    let account = self.realm.object(ofType: Account.self, forPrimaryKey: "Main")
                    account!.trades.append(trade)
                    account!.profitAndLoss += trade.p_l
                    account!.balance += (trade.p_l - trade.fees)
                    account!.fees += trade.fees
                }
            }
        }
        self.getWinRate()
    }
    
    func addNewtoTrade(trade: Trade, news: [News]){
        try! realm.write{
            
        }
    }
    
    func addNews(news: [News]){
        try! realm.write{
            for i in news{
                self.realm.add(i)
            }
        }
    }
    
    func reAddTrades(trades: [Trade]){
        let account = realm.object(ofType: Account.self, forPrimaryKey: "Main")
        realm.beginWrite()
       
        
        for i in trades{
            i.isDeleted = false

        }
        try! realm.commitWrite()
        getWinRate()
        
    }
    
    func toggleTradeIsDeleted(trade: Trade){
        try! realm.write {
            trade.isDeleted = true
        }
    }
    
    func deleteTrades(trades: [Trade]){
        try! realm.write{ [self] in
            realm.delete(trades)
        }
    }
    
    func resetAccount(newVal: String) {
        try! realm.write { [self] in
            let account = realm.object(ofType: Account.self, forPrimaryKey: "Main")
            account!.trades.removeAll()
            account!.profitAndLoss = 0
            account!.balance = try! Decimal128(string: newVal)
            account!.fees = 0
        }
    }
    
    func resetBalance(newVal: String) {
        try! realm.write { [self] in
            let account = realm.object(ofType: Account.self, forPrimaryKey: "Main")
            account!.balance = try! Decimal128(string: newVal)
        }
    }
    
    func updateAccountAfterTradeDelete(trade: Trade){
        try! realm.write { [self] in
            if !trade.isHindsight{
                let account = realm.object(ofType: Account.self, forPrimaryKey: "Main")
    //            account!.trades.remove(at: trades.firstIndex(of: trade)!)
                account!.profitAndLoss -= trade.p_l
                account!.balance -= trade.p_l
                account!.balance += trade.fees
                account!.fees -= trade.fees
            }
            
        }
    }
    
    func updateTradeNotes(trade: Trade, notes: String){
        try! realm.write{
            trade.notes = notes
        }
    }


    func addWin() {
        let temp = Trade()
        temp.win = true
        temp.loss = false
        try! realm.write{
            realm.add(temp)
        }
        getWinRate()
    }

    func addLoss() {
        let temp = Trade()
        temp.loss = true
        temp.win = false
        try! realm.write{
            realm.add(temp)
        }
        getWinRate()
    }
    
    func deleteAll() {
        var tempDirectoires: [String] = []
        for i in realm.objects(Trade.self) {
            if i.photoDirectory != nil{
                tempDirectoires.append(i.photoDirectory!)
            }
        }
        myImage.deleteAllImages(directories: tempDirectoires)
        resetAccount(newVal: "3000.00")
        try! realm.write {
            realm.deleteAll()
        }
        setDefaults()
    }
    

}

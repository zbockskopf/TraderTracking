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
    @Published var streak: String = ""
    @Published var last50: String = ""
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
    @ObservedResults(News.self) var news
    @ObservedResults(Symbol.self) var symbols
    @ObservedResults(News.self, filter: NSPredicate(format: "date = %@", Calendar.current.startOfDay(for: Date()) as CVarArg)) var todayNews
//    @Published var trades: [Trade] = []
//    @Published var symbols: [Symbol] = []
    @ObservedResults(Account.self) var accounts
    @ObservedRealmObject var currentAccount: Account
    
    var realm: Realm!
    var myImage: MyImages!
    var account: Account!
    private var hasLaunched = UserDefaults.standard.bool(forKey: "launchedBefore")

    static let shared = RealmController()
    let myFormatter = MyFormatter()
//    var forex = ForexCrawler()
//    var realmQue =  DispatchQueue(label: "realm")
    
    override init() {
        
        let config = Realm.Configuration(schemaVersion: 12,
                                                 migrationBlock: { migration, oldSchemaVersion in

                                                    if (oldSchemaVersion <= 11){
                                                        migration.enumerateObjects(ofType: Trade.className()) { (old, new) in
                                                            new!["reviewed"] = false
                                                            
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
            
            
//        }
        self.currentAccount = realm.object(ofType: Account.self, forPrimaryKey: "Main")!
        super.init()
        if !hasLaunched {
            setDefaults()
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }else{
            self.account = realm.object(ofType: Account.self, forPrimaryKey: "Main")!
        }
        
        getWinRate()
        updateCurWeeklyGoal()
        getTradesPL()
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last)
        try! realm.write {
//            account.streak = 2
//            var temp: Decimal128 = 0
//            account.curWeeklyGoal = 0
//            account.curWeeklyGoal = {
//                for i in account.trades.filter("win = true AND isHindsight = false AND isDeleted = false"){
//                    if i.exit != i.entry {
//                        if i.positionType == .long {
//                            temp += i.exit - i.entry
//                        }else{
//                            temp += i.entry - i.exit
//                        }
//                    }else{
//                        return temp
//                    }
//                }
//                return temp
//            }()
            
            
//            let temp = account.archiveTrades
//            account.trades.append(objectsIn: temp)
//            account.archiveTrades.removeAll()
        }
        
//        let account = realm.object(ofType: Account.self, forPrimaryKey: "Main")
//        for i in 0...25 {
//            var temp = Trade()
//            temp.symbol = realm.object(ofType: Symbol.self, forPrimaryKey: "MES")
//            temp.dateEntered = Date()
//            temp.dateExited = Date()
//            temp.entry = 1
//            temp.exit = 2
//            temp.positionSize = 1
//            temp.positionType = .long
//            temp.session = .ny
//            temp.fees = 5.14
//            temp.win = true
//            temp.loss = false
//            temp.p_l = 5
//            temp.isHindsight = false
//            addTrade(trade: temp, images: nil, edited: false)
//        }
//
//        for i in 0...25 {
//            var temp = Trade()
//            temp.symbol = realm.object(ofType: Symbol.self, forPrimaryKey: "MES")
//            temp.dateEntered = Date()
//            temp.dateExited = Date()
//            temp.entry = 2
//            temp.exit = 1
//            temp.positionSize = 1
//            temp.positionType = .long
//            temp.session = .ny
//            temp.fees = 5.14
//            temp.win = false
//            temp.loss = true
//            temp.p_l = -5
//            addTrade(trade: temp, images: nil, edited: false)
//        }
//        let temp = Double(account.trades.filter("isHindsight = false").suffix(50).filter{$0.win == true}.count)
//        let temp1 = Double(account.trades.filter("isHindsight = false").suffix(50).count)
//        print(temp, temp1)
//        print(Float(temp/temp1))
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
        account.streak = 0
        account.bestStreak = 0

        try! realm.write{
            realm.add(temp1)
            realm.add(temp2)
            realm.add(account)
        }
        self.account = realm.object(ofType: Account.self, forPrimaryKey: "Main")!
    }
    
    func createAccount() {
        let account = Account()
        account.name = "Main"
        account.balance = 3000.00
        account.streak = 0
        account.bestStreak = 0
        
        try! realm.write{
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
        print(symbols)
        return symbols
    }


    func getWinRate() {
        let wins = Double(account.trades.filter("dateEntered BETWEEN {%@, %@} AND win = true AND isHindsight = false AND isDeleted = false", Date().currentWeekdays.first!, Date()).count)
        let losses = Double(account.trades.filter("dateEntered BETWEEN {%@, %@} AND loss = true AND isHindsight = false AND isDeleted = false", Date().currentWeekdays.first!, Date()).count)
        var temp: Double = Double((wins/(wins + losses)))
        numWins = String(Int(wins))
        numLosses = String(Int(losses))
        
        if wins == 0.0 && losses == 0.0 {
            winRate = "No Trades"
        }else{
            winRate = myFormatter.percentFormat(num: temp)
        }
        
//        getTradesPL()
        
    }
    
    func getTradesPL() {
        var temp: Decimal128 = 0.0
        for i in account.trades {
            if !i.isHindsight{
                temp += i.p_l
            }
        }
        pAndL = myFormatter.numFormat(num: temp)
    }
    
    func getWeekPandL(hindSight: Bool) -> String{
        var temp: Decimal128 = 0.0
        for i in account.trades.filter("dateEntered BETWEEN {%@, %@} AND isDeleted = false AND isHindsight = %@",
                                       Date().currentWeekdays.first!, Date(), hindSight).sorted(byKeyPath: "dateEntered", ascending: false) {
            if !i.isHindsight{
                temp += i.p_l
            }
        }
        return myFormatter.numFormat(num: temp)
    }
    
    func getHindSightPL() -> String {
        var temp: Decimal128 = 0.0
        for i in account.trades {
            if i.isHindsight{
                temp += i.p_l
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
                    account.profitAndLoss += trade.p_l
                    account.balance += (trade.p_l - trade.fees)
                    account.fees += trade.fees
                    if trade.win! {
                        account.streak += 1
                        if account.streak > account.bestStreak {
                            account.bestStreak = account.streak
                        }
                    }else{
                        account.streak = 0
                    }
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
                account.trades.append(trade)
                if !trade.isHindsight{
                    
                    account.profitAndLoss += trade.p_l
                    account.balance += (trade.p_l - trade.fees)
                    account.fees += trade.fees
                    if trade.win! {
                        account.streak += 1
                        if account.streak > account.bestStreak {
                            account.bestStreak = account.streak
                        }
                    }else{
                        account.streak = 0
                    }
                }
            }
        }
        self.updateCurWeeklyGoal()
        self.getWinRate()
    }
    
    func tradeReviewed(trade: Trade){
        var temp = trade.thaw()
        try! realm.write{
            temp!.reviewed.toggle()
        }
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
            account!.streak = 0
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
                account.profitAndLoss -= trade.p_l
                account.balance -= trade.p_l
                account.balance += trade.fees
                account.fees -= trade.fees
                account.curWeeklyGoal -= trade.handles
            }
            
        }
    }
    
    func archiveTrades() {
        try! realm.write { [self] in
            let trades = account.trades
            account.archiveTrades.append(objectsIn: trades)
            account.trades.removeAll()
            account.streak = 0
        }
        getWinRate()
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
    
    func setWeeklyGoal(newVal: String){
        try! realm.write{
            account.weeklyGoal = Int(newVal) ?? 0
        }
    }
    
    func updateCurWeeklyGoal() {
        try! realm.write{
            account.curWeeklyGoal = 0
            for i in account.trades.filter("dateEntered BETWEEN {%@, %@} AND isHindsight = false AND isDeleted = false", Date().currentWeekdays.first!, Date()){
                account.curWeeklyGoal += i.handles
            }
        }
    }
}

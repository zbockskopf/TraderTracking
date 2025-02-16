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
    @ObservedResults(Account.self) var accounts
    @ObservedResults(News.self) var news
    @ObservedResults(Symbol.self) var symbols
    @ObservedResults(News.self, filter: NSPredicate(format: "date = %@", Calendar.current.startOfDay(for: Date()) as CVarArg)) var todayNews
//    @Published var trades: [Trade] = []
//    @Published var symbols: [Symbol] = []
//    @ObservedResults(Account.self) var accounts
//    @ObservedRealmObject var currentAccount: Account
    
    var realm: Realm!
    var myImage: MyImages!
    var account: Account!
    var tradeJounalEnties: Results<Trade_Journal>!
    
    private var hasLaunched = UserDefaults.standard.bool(forKey: "launchedBefore")

    static let shared = RealmController()
    let myFormatter = MyFormatter()
    let helper = MyHelper()
//    var forex = ForexCrawler()
//    var realmQue =  DispatchQueue(label: "realm")
    
    override init() {
//        UserDefaults.standard.set("Main", forKey: "currentAccount")
        let config = Realm.Configuration(schemaVersion: 0,
                                                 migrationBlock: { migration, oldSchemaVersion in

                                                    
        })
                
                Realm.Configuration.defaultConfiguration = config
        
//        realmQue.sync {
            realm = try! Realm()
            myImage = MyImages()
            
            
//        }
//        self.currentAccount = realm.object(ofType: Account.self, forPrimaryKey: "Main")!
        super.init()

        if !hasLaunched {
            setDefaults()
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }else{
            self.account = realm.object(ofType: Account.self, forPrimaryKey: UserDefaults.standard.string(forKey: "currentAccount"))!
            self.tradeJounalEnties = realm.objects(Trade_Journal.self)
        }
        
        getWinRate()
        updateCurWeeklyGoal()
        getTradesPL()
//        addToMain()
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!)
        try! realm.write {
//            let temp5 = Symbol()
//            temp5.name = "6E"
//            temp5.market = "Forex"
//            temp5.tickValue = 12.50
//            realm.add(temp5)
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
        temp1.fees = Decimal128(floatLiteral: 1.74)

        let temp2 = Symbol()
        temp2.name = "MNQ"
        temp2.market = "Futures"
        temp2.tickValue = 0.50
        temp2.fees = Decimal128(floatLiteral: 1.74)
        
        let temp3 = Symbol()
        temp3.name = "ES"
        temp3.market = "Futures"
        temp3.tickValue = 12.50
        temp3.fees = Decimal128(floatLiteral: 4.68)
        
        let temp4 = Symbol()
        temp4.name = "NQ"
        temp4.market = "Futures"
        temp4.tickValue = 5.00
        temp4.fees = Decimal128(floatLiteral: 4.68)
        
        let temp5 = Symbol()
        temp5.name = "6E"
        temp5.market = "Forex"
        temp5.tickValue = 12.50
        temp5.fees = Decimal128(floatLiteral: 4.72)
        
        let temp6 = Symbol()
        temp6.name = "MCL"
        temp6.market = "Futures"
        temp6.tickValue = 1.00
        temp6.fees = Decimal128(floatLiteral: 1.74)
        
        let temp7 = Symbol()
        temp7.name = "CL"
        temp7.market = "Futures"
        temp7.tickValue = 10.00
        temp7.fees = Decimal128(floatLiteral: 4.92)
        
        let temp8 = Symbol()
        temp8.name = "YM"
        temp8.market = "Futures"
        temp8.tickValue = 1.25
        temp8.fees = Decimal128(floatLiteral: 5.68)
        
        let account = Account()
        account.name = "Main"
        account.balance = 3000.00
        account.streak = 0
        account.bestStreak = 0

        try! realm.write{
            realm.add(temp1)
            realm.add(temp2)
            realm.add(temp3)
            realm.add(temp4)
            realm.add(temp5)
            realm.add(temp6)
            realm.add(temp7)
            realm.add(temp8)
            realm.add(account)
        }
        self.account = realm.object(ofType: Account.self, forPrimaryKey: "Main")!
        UserDefaults.standard.set(account.name, forKey: "currentAccount")
    }
    
    // MARK: - Account Methods
    
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
    
    func newAccount(name: String, balance: String) {
        try! realm.write{
            let temp = Account()
            temp.name = name
            temp.balance = Decimal128(stringLiteral: balance)
            realm.add(temp)
            self.account = realm.object(ofType: Account.self, forPrimaryKey: name)
        }
        
    }
    
    func switchAccount(name: String) {
        self.account = realm.object(ofType: Account.self, forPrimaryKey: name)
        UserDefaults.standard.set(name, forKey: "currentAccount")
        MenuController.shared.selection = 0
        getWinRate()
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
    
    func upateAccountAfterTradeUndo(trade: Trade){
        try! realm.write { [self] in
            if !trade.isHindsight{
                account.profitAndLoss += trade.p_l
                account.balance += trade.p_l
                account.balance -= trade.fees
                account.fees += trade.fees
                account.curWeeklyGoal += trade.handles
            }
            
        }
    }
    
    func resetAccount(newVal: String) {
        try! realm.write { [self] in
//            let account = realm.object(ofType: Account.self, forPrimaryKey: "Main")
            account.trades.removeAll()
            account.profitAndLoss = 0
            account.balance = try! Decimal128(string: newVal)
            account.fees = 0
            account.streak = 0
            account.curWeeklyGoal = 0
            account.weeklyGoal = 0
        }
    }
    
    func resetBalance(newVal: String) {
        try! realm.write { [self] in
//            let account = realm.object(ofType: Account.self, forPrimaryKey: "Main")
            account.balance = try! Decimal128(string: newVal)
        }
    }
    
    func updateAccountDailyBalance() {
        if let previousDayP_l: Decimal128 = account.trades.filter("dateEntered BETWEEN {%@, %@}", Calendar.current.startOfDay(for: Date().previousDay()),Date().previousDay().endOfDay()).sum(ofProperty: "p_l"){
            try! realm.write {
                if (account.balanceChange.first(where: {$0.date == Calendar.current.startOfDay(for: Date().previousDay())}) != nil){
                    
                    account.balanceChange.append(AccontBalanceChange(accountName: account.name, firstElement: Date().previousDay(), secondElement: previousDayP_l + (account.balanceChange.last?.balance ?? account.balance)))
                    
                }else{
                    account.balanceChange.append(AccontBalanceChange(accountName: account.name, firstElement: Date().previousDay(), secondElement: previousDayP_l + (account.balanceChange.last?.balance ?? account.balance)))
                }
            }
        }

    }
    
    func updateAccountDailyBalanceAfterImport(orders: [(ImportOrder, [ImportOrder], [ImportOrder], ImportOrder?, ImportOrder?)]){
//        var sorted = orders.sorted(by: {$0.0.timestamp < $1.0.timestamp})
        for i in 0...orders.count - 1{
            var day = myFormatter.convertImportDate(date: orders[i].0.fillTime)
             let dayPnL: Decimal128 = (account.trades.filter("dateEntered BETWEEN {%@, %@}", Calendar.current.startOfDay(for: day), day.endOfDay()).sum(ofProperty: "p_l") - account.trades.filter("dateEntered BETWEEN {%@, %@}", Calendar.current.startOfDay(for: day), day.endOfDay()).sum(ofProperty: "fees"))
                try! realm.write {
                    if (account.balanceChange.first(where: {$0.date == Calendar.current.startOfDay(for: day)}) == nil){
                        account.balanceChange.append(AccontBalanceChange(accountName: account.name, firstElement: Calendar.current.startOfDay(for: day), secondElement: dayPnL + (account.balanceChange.first(where: {$0.date == Calendar.current.startOfDay(for: day.previousDay())})?.balance ?? account.balance)))
                    }
                }
            
        }
    }
    
//    func updateAccountDailyBalanceAfterImport(firstImportTradeDate: Date){
//        
//        
//        for i in 0...account.trades.filter("dateEntered > %@", Calendar.current.startOfDay(for: firstImportTradeDate)).count{
//            var day = Calendar.current.date(byAdding: .day, value: i, to: firstImportTradeDate)!
//            if let dayPnL: Decimal128 = account.trades.filter("dateEntered BETWEEN {%@, %@}", Calendar.current.startOfDay(for: day), day.endOfDay()).sum(ofProperty: "p_l"){
//                try! realm.write {
//                    if (account.balanceChange.first(where: {$0.date == Calendar.current.startOfDay(for: day)}) != nil){
//                        account.balanceChange.append(AccontBalanceChange(accountName: account.name, firstElement: Calendar.current.startOfDay(for: day), secondElement: dayPnL + account.balance))
//                    }else{
//                        account.balanceChange.append(AccontBalanceChange(accountName: account.name, firstElement: Calendar.current.startOfDay(for: day), secondElement: dayPnL + (account.balanceChange.first(where: {$0.date == Calendar.current.startOfDay(for: day.previousDay())})?.balance ?? account.balance)))
//                    }
//                }
//            }
//        }
//    }
    
    // MARK: - Trade Methods
    
    func getTrades() -> [Trade] {
        var trades: [Trade] = []
        for i in realm.objects(Trade.self).distinct(by: ["_id"]){
            trades.append(i)
        }
        return trades
    }
    
    func addTrade(trade: Trade, images: [UIImage]?, edited: Bool){
        if edited {
            try! self.realm.write{ [self] in
                realm.create(Trade.self, value: trade, update: .all)
//                self.realm.add(trade, update: .all)
                
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
    
    func deletePartials(partials: [Partial]){
        try! realm.write{
            realm.delete(partials)
        }
    }
    
    func updatePartial(partial: Partial, order: Int, exit: String, exitDate: Date, size: String){
        let thaw = partial.thaw()!
        try! realm.write{
            thaw.order = order
            thaw.exit = Decimal128(stringLiteral: exit)
            thaw.dateExited = exitDate
            thaw.positionSize = Double(size)!
        }
    }
    
    func updatePartialPnL(partial: Partial, pnl: Decimal128 ){
        let p = realm.object(ofType: Partial.self, forPrimaryKey: partial._id)!
        try! realm.write{
            p.p_l = pnl
        }
    }
    
    func tradeReviewed(trade: Trade){
        let temp = trade.thaw()
        try! realm.write{
            temp!.reviewed.toggle()
        }
    }
    
    func addNewtoTrade(trade: Trade, news: [News]){
        try! realm.write{
            
        }
    }
    
    func addImportOrders(orders: [(ImportOrder, [ImportOrder], [ImportOrder], ImportOrder?, ImportOrder?)]){
        let ntc = NewTradeController()
        try! realm.write {
            for order in orders {
//                print("New order\n", order)
                let importAccount = accounts.first(where: {$0.name == order.0.account}) ?? {
                    let temp = Account()
                    temp.name = order.0.account
                    temp.balance = Decimal128(stringLiteral: "50000")
                    realm.add(temp)
                    
                    return accounts.first(where: {$0.name == order.0.account})!
                }()
                let tempTrade = Trade()
                print(order.0.product)
                print(symbols)
                tempTrade.symbol = symbols.first(where: {order.0.product.contains($0.name)})
                print(tempTrade.symbol)
//                print(order.0.fillTime)
                tempTrade.dateEntered = myFormatter.convertImportDate(date: order.0.fillTime)
                print(tempTrade.dateEntered, "\n")
                tempTrade.entry = ntc.formatDecimal(str: order.0.avgFillPrice)
                print(tempTrade.entry)
                if order.2.count == 0 {
                    tempTrade.dateExited = myFormatter.convertImportDate(date: order.3?.fillTime ?? "")
                }else{
                    tempTrade.dateExited = Date()
                }
                tempTrade.exit = order.2.count != 0 ? 0 : ntc.formatDecimal(str: order.3!.avgFillPrice)
                tempTrade.positionSize = ((order.2.count) > 0 ? ntc.getImportPositionSize(partials: order.2) : Double(order.3?.filledQty ?? ""))!
                tempTrade.positionType = order.0.bs.contains("Buy") ? .long : .short
                tempTrade.session = .ny
//                tempTrade.takeProfit
                tempTrade.fees = Decimal128(floatLiteral: (tempTrade.positionSize * tempTrade.symbol!.fees.doubleValue))
                //            tempTrade.partials =
//                print(order.0.orderId, tempTrade.fees, String(tempTrade.positionSize * tempTrade.symbol!.fees.doubleValue), Decimal128(floatLiteral: (tempTrade.positionSize * tempTrade.symbol!.fees.doubleValue)))
                tempTrade.p_l = ntc.getImportProfitLoss(order: order, symbol: tempTrade.symbol!)
                tempTrade.partials.append(objectsIn: ntc.convertImportPartils(orders: order.2))
                tempTrade.handles = ntc.getHandles(entry: tempTrade.entry, exit: tempTrade.exit, positionType: tempTrade.positionType, partials: tempTrade.partials)
                tempTrade.percentGain = tempTrade.p_l .doubleValue / importAccount.balance.doubleValue
                if tempTrade.p_l.isGreaterThan(Decimal128(0.0)){
                    tempTrade.win = true
                    tempTrade.loss = false
                }else{
                    tempTrade.win = false
                    tempTrade.loss = true
                }
                tempTrade.stopLoss = order.4 != nil ? try! Decimal128(string: order.4!.stopPrice) : tempTrade.loss ?? false ? tempTrade.exit : nil
                tempTrade.riskToReward = ntc.getRR(entry: tempTrade.entry, exit: tempTrade.exit, stopLoss: tempTrade.stopLoss, takeProfit: tempTrade.takeProfit, type: tempTrade.positionType, partials: tempTrade.partials)
                
                
                realm.add(tempTrade)
                
                importAccount.trades.append(tempTrade)
                let main = realm.objects(Account.self).filter("name = %@", "Main").first!
                
                main.trades.append(tempTrade)
                if !tempTrade.isHindsight{
                    importAccount.profitAndLoss += tempTrade.p_l
                    importAccount.balance += (tempTrade.p_l - tempTrade.fees)
                    importAccount.fees += tempTrade.fees
                    
                    main.profitAndLoss += tempTrade.p_l
                    main.balance += (tempTrade.p_l - tempTrade.fees)
                    main.fees += tempTrade.fees
                    if tempTrade.win! {
                        importAccount.streak += 1
                        if importAccount.streak > importAccount.bestStreak {
                            importAccount.bestStreak = importAccount.streak
                        }
                        
                        main.streak += 1
                        if main.streak > main.bestStreak {
                            main.bestStreak = main.streak
                        }
                    }else{
                        importAccount.streak = 0
                        main.streak = 0
                    }
                }
            }
        }
        switchAccount(name: orders.first!.0.account)
        self.updateCurWeeklyGoal()
        self.getWinRate()
//        self.updateAccountDailyBalanceAfterImport(firstImportTradeDate: myFormatter.convertImportDate(date:  orders.min(by: {myFormatter.convertImportDate(date: $0.0.timestamp) < myFormatter.convertImportDate(date: $1.0.timestamp)})!.0.timestamp))
        self.updateAccountDailyBalanceAfterImport(orders: orders.sorted(by: {myFormatter.convertImportDate(date: $0.0.timestamp) < myFormatter.convertImportDate(date: $1.0.timestamp)}))
        
    }
    
    func addNinjaTraderTrades(_ trades: [Trade]){
        try! realm.write {
            let importAccount = accounts.first(where: {$0.name == "Main"})
            importAccount?.trades.append(objectsIn: trades)
        }
    }
    
    func deleteTrades(trades: [Trade]){
        try! realm.write{ [self] in
            realm.delete(trades)
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
    
    func toggleTradeIsDeleted(trade: Trade){
        try! realm.write {
            let t = trade.thaw()!
            t.isDeleted = true
        }
    }
    
    func deleteAllDeletedTrades() {
        try! realm.write { [self] in
            let trades = realm.objects(Trade.self).filter("isDeleted = true")
            for i in trades{
                realm.delete(i.partials)
            }
            realm.delete(trades)
        }
    }
    
    func updateTradeNotes(trade: Trade, notes: String){
        try! realm.write{
            trade.notes = notes
        }
    }
    
    func reAddTrades(trades: [Trade]){
//        let account = realm.object(ofType: Account.self, forPrimaryKey: "Main")
        realm.beginWrite()
       
        
        for i in trades{
            let t = i.thaw()!
            t.isDeleted = false

        }
        try! realm.commitWrite()
        getWinRate()
        
    }
    

    // MARK: - Other
    
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
        let temp: Double = Double((wins/(wins + losses)))
        numWins = String(Int(wins))
        numLosses = String(Int(losses))
        
        if wins == 0.0 && losses == 0.0 {
            winRate = "No Trades"
        }else{
            winRate = myFormatter.percentFormat(num: temp)
        }
        getStreak()
//        getTradesPL()
        
    }
    
    func getTradesPL() {
        var temp: Decimal128 = 0.0
        for i in account.trades {
            if !i.isHindsight{
                temp += i.p_l - i.fees
            }
        }
        pAndL = myFormatter.numFormat(num: temp)
    }
    
    func getWeekPandL(hindSight: Bool) -> String{
        var temp: Decimal128 = 0.0
        for i in account.trades.filter("dateEntered BETWEEN {%@, %@} AND isDeleted = false AND isHindsight = %@",
                                       Date().currentWeekdays.first!, Date(), hindSight).sorted(byKeyPath: "dateEntered", ascending: false) {
//            if !i.isHindsight{
            temp += i.p_l - i.fees
//            }
        }
        return myFormatter.numFormat(num: temp)
    }
    
    func getHindSightPL() -> String {
        var temp: Decimal128 = 0.0
        for i in account.trades {
            if i.isHindsight{
                temp += i.p_l - i.fees
            }
        }
        return myFormatter.numFormat(num: temp)
    }
    
    
    
    func addNews(news: [News]){
        try! realm.write{
            for i in news{
                self.realm.add(i)
            }
        }
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
        deleteJournal()
        setDefaults()
    }
    
    func deleteJournal(){
        let trades = realm.objects(Trade_Journal.self)
        let forecasts = realm.objects(Forecast_Journal.self)
        let reviews = realm.objects(Review_Journal.self)
        try! realm.write{
            realm.delete(trades)
            realm.delete(forecasts)
            realm.delete(reviews)
        }
        // Discord refresh
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2015
        components.month = 5
        components.day = 13

        if let discordReleaseDate = calendar.date(from: components) {
            print("Discord release date: \(discordReleaseDate)")
            UserDefaults.standard.set(discordReleaseDate, forKey: "discordLastTradeFetched")
            UserDefaults.standard.set(discordReleaseDate, forKey: "discordLastForecastFetched")
            UserDefaults.standard.set(discordReleaseDate, forKey: "discordLastReviewFetched")
        }
        
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
        
    func getStreak() {
        var count = 0
        for i in account.trades.sorted(byKeyPath: "dateEntered", ascending: false){
            if i.win ?? false{
                if !i.isHindsight{
                    count += 1
                }
            }else{
                break
            }
        }
        streak = String(count)
    }

}


//extension Realm {
//    static var preview: Realm {
//        let configuration = Realm.Configuration(inMemoryIdentifier: "preview")
//        return try! Realm(configuration: configuration)
//    }
//}
//
//extension Realm {
//    func addSampleData() {
//        let temp1 = Symbol()
//        temp1.name = "MES"
//        temp1.market = "Futures"
//        temp1.tickValue = 1.25
//        temp1.fees = Decimal128(floatLiteral: 1.34)
//
//        let temp2 = Symbol()
//        temp2.name = "MNQ"
//        temp2.market = "Futures"
//        temp2.tickValue = 0.50
//        temp2.fees = Decimal128(floatLiteral: 1.34)
//        
//        let temp3 = Symbol()
//        temp3.name = "ES"
//        temp3.market = "Futures"
//        temp3.tickValue = 12.50
//        temp3.fees = Decimal128(floatLiteral: 4.18)
//        
//        let temp4 = Symbol()
//        temp4.name = "NQ"
//        temp4.market = "Futures"
//        temp4.tickValue = 5.00
//        temp4.fees = Decimal128(floatLiteral: 4.18)
//        
//        let temp5 = Symbol()
//        temp5.name = "6E"
//        temp5.market = "Forex"
//        temp5.tickValue = 12.50
//        temp5.fees = Decimal128(floatLiteral: 4.72)
//        
//        let account = Account()
//        account.name = "Main"
//        account.balance = 3000.00
//        account.streak = 0
//        account.bestStreak = 0
//
//        try! write{
//            add(temp1)
//            add(temp2)
//            add(temp3)
//            add(temp4)
//            add(temp5)
//            add(account)
//        }
//        self.account = realm.object(ofType: Account.self, forPrimaryKey: "Main")!
//        UserDefaults.standard.set(account.name, forKey: "currentAccount")
//    }
//}

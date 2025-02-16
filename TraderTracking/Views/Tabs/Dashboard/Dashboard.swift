import SwiftUI
import SwiftPieChart
import RealmSwift
import ConfettiSwiftUI
import UniformTypeIdentifiers

struct Dashboard: View {
    @EnvironmentObject var realmController: RealmController
    @EnvironmentObject var notifications: MyNotifications
    @EnvironmentObject var menuController: MenuController
    @EnvironmentObject var newsController: ForexCrawler
    @StateObject var controller: DashBoardController = DashBoardController()
    @State private var showFileImporter = false
    @State private var csvData: String = ""
    @State private var sheetAction: SheetAction? = .nothing
    @State private var confettiCounter: Int = 0
    @State private var showNewTrade = false
    @State private var showImportOrders = false
    @State private var showNinjaTraderImporter = false
    @Binding var showMenu: Bool
    @Binding var offSet: CGFloat

    private let myFormatter = MyFormatter()
    private let newTradeButtonWidth: CGFloat = 200
    private let stats = ["P&L", "# Trades", "%", "Avg RR"]
    
    
    @Namespace var transitionId
    @State private var calendarViewIsExpanded = false
    @State private var statsViewIsExpanded = false

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    mainContent
                }
                BlurBackground(showMenu: $showMenu, offSet: $offSet)
                HiddenNavigationView()
                    .environmentObject(menuController)
                    .environmentObject(notifications)
                    .environmentObject(realmController)
                addButton
            }
            .navigationTitle("")
            .navigationBarItems(leading: leadingNavigationBarButton, trailing: trailingNavigationBarButton)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var mainContent: some View {
        List {
            HStack {
                Text(realmController.account.name)
                    .font(.title2)
                Spacer()
                Button {
                    // When tapped, set the state to true to trigger the NavigationLink.
                    calendarViewIsExpanded = true
                } label: {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .foregroundStyle(.green)
                }
            }
            ZStack{
                MonthView(
                    currentMonthDate: Date(),
                    trades: realmController.account.trades.filter(
                        "dateEntered BETWEEN {%@, %@} AND isDeleted = false",
                        Date().startOfMonth(),
                        Date().endOfMonth()
                    ),
                    showCalendarView: $menuController.showCalendarView,
                    showCurrentMonthOnly: true
                )
                .navigationDestination(isPresented: $calendarViewIsExpanded,  destination: {
                    LazyView {
                        ScrollableMonthView(onDismiss: {
                            menuController.showListView = false
                        })
                        .environmentObject(realmController)
                        .navigationTransition(.zoom(sourceID: "monthViewTransition", in: transitionId))
                    }
                })
                .buttonStyle(PlainButtonStyle()) // Removes default button styling.
            }
            .matchedTransitionSource(id: "monthViewTransition", in: transitionId)

            monthlyStatsSection
            if UserDefaults.standard.bool(forKey: "personalDevice"){
                balanceSection
            }
        }
        .scrollIndicators(.hidden)
    }

    private var monthlyStatsSection: some View {
        Section {
            HStack{
                Text("Monthly Stats").bold()
                Spacer()
                Button {
                    statsViewIsExpanded = true
                } label: {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .foregroundStyle(.green)
                }
            }
            
            VStack {
                statsGrid
                    .navigationDestination(isPresented: $statsViewIsExpanded,  destination: {
                        LazyView {
                            StatsView(onDismiss: {
                                menuController.showListView = false
                            })
                            .environmentObject(realmController)
                            .navigationTransition(.zoom(sourceID: "statsViewTransition", in: transitionId))
                        }
                    })
                    
                winRateSection
            }
            .matchedTransitionSource(id: "statsViewTransition", in: transitionId)
        }

    }

    private var statsGrid: some View {
        VStack {
            LazyVGrid(columns: gridItems, spacing: 5) {
                ForEach(stats, id: \.self) { stat in
                    Text(stat).fontWeight(.bold)
                }
            }

            LazyVGrid(columns: gridItems, spacing: 5) {
                let monthlyTrades = realmController.account.trades.filter("dateEntered BETWEEN {%@, %@} AND isDeleted = false", Date().startOfMonth(), Date().endOfMonth())
                let start = Date().startOfMonth()
                let end = Date().endOfMonth()

                let wins: Decimal128 = realmController.account.trades
                    .filter("dateEntered >= %@ AND dateEntered <= %@ AND isDeleted = false AND win = true", start, end)
                    .sum(ofProperty: "p_l")

                let losses: Decimal128  = realmController.account.trades
                    .filter("dateEntered >= %@ AND dateEntered <= %@ AND isDeleted = false AND loss = true", start, end)
                    .sum(ofProperty: "p_l")

                let RR: Double = wins.doubleValue / abs(losses.doubleValue)
                
                ForEach(0..<4, id: \.self) { index in
                    switch index {
                    case 0:
                        let p_l: Decimal128 = monthlyTrades.sum(ofProperty: "p_l")
                        let fees: Decimal128 = monthlyTrades.sum(ofProperty: "fees")
                        Text(myFormatter.numFormat(num: p_l - fees))
                    case 1:
                        Text("\(monthlyTrades.count)")
                    case 2:
                        let p_l: Decimal128 = monthlyTrades.sum(ofProperty: "p_l")
                        let accountBalanceBefore = realmController.account.balance - p_l
                        Text(myFormatter.percentFormat(num: Double(p_l.doubleValue / accountBalanceBefore.doubleValue)))
                    case 3:

//                        let sumRR: Double = monthlyTrades.filter("riskToReward > 0").sum(ofProperty: "riskToReward")
//                        let RR: Double = Double(sumRR / Double(monthlyTrades.filter("riskToReward > 0").count))
                        
                        Text(String(format: "%.2f", RR))
                    default:
                        Text("")
                    }
                }
            }
        }
    }

    private var winRateSection: some View {
        VStack {
            HStack { Spacer(); Text("Win Rate").bold(); Spacer() }
            HStack {
                WinRatePieChart(
                    wins: Double(realmController.account.trades.filter("dateEntered BETWEEN {%@, %@} AND isDeleted = false AND win = true", Date().startOfMonth(), Date().endOfMonth()).count),
                    losses: Double(realmController.account.trades.filter("dateEntered BETWEEN {%@, %@} AND isDeleted = false AND loss = true", Date().startOfMonth(), Date().endOfMonth()).count)
                )
                Spacer()
            }
        }
    }

    private var balanceSection: some View {
        Section {
            Text("Balance").bold()
//            AccontBalanceLineChart(balance: $controller.accountBalanceData, yAxisRange: $controller.accountYAxis)
//                .onAppear {
//                    controller.updateAccountBalanceData(realmController: realmController)
//                }
        }
    }

    private var addButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    if menuController.currentTradeButtonFunction == "Import Orders" {
                        showFileImporter.toggle()
                    }else if menuController.currentTradeButtonFunction == "NewTrade"{
                        showNewTrade.toggle()
                    } else {
                        showNinjaTraderImporter.toggle()
                        
                    }
                }) { 
                    buttonImage
                }
                .confettiCannon(counter: $confettiCounter, num: 250, confettis: [.shape(.slimRectangle), .shape(.square)], colors: [.green], rainHeight: 700, openingAngle: .degrees(35), closingAngle: .degrees(145), radius: 400)
                .sheet(isPresented: $showNewTrade, onDismiss: handleNewTradeDismiss) {
                    NewTradeView(sheetAction: $sheetAction, isEditing: false)
                        .environmentObject(realmController)
                        .environmentObject(newsController)
                }
                .fileImporter(
                    isPresented: $showFileImporter,
                    allowedContentTypes: [UTType.commaSeparatedText],
                    allowsMultipleSelection: true,
                    onCompletion: handleFileImport
                )
                .fileImporter(
                    isPresented: $showNinjaTraderImporter,
                    allowedContentTypes: [UTType.commaSeparatedText],
                    allowsMultipleSelection: true,
                    onCompletion: handleNinjaTraderImoprt
                )
                
                .contextMenu {
                    if UserDefaults.standard.bool(forKey: "personalDevice"){
                        contextMenu
                    }
                }
                .padding()
            }
        }
    }

    private var buttonImage: some View {
        if menuController.currentTradeButtonFunction.contains("Orders") ||  menuController.currentTradeButtonFunction.contains("NewTrade"){
            return AnyView(Image(systemName: menuController.currentTradeButtonFunction.contains("Orders") ? "square.and.arrow.down" : "plus")
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .clipShape(Circle()))
        }else{
            return AnyView(Text("🥷🏽")
                .font(.system(size: 25)) // Adjust the size as needed
                .padding()
                .background(.green)
                .clipShape(Circle()))
        }

    }

    private var contextMenu: some View {
        Group {
            if menuController.currentTradeButtonFunction == "Import Orders" {
                Button("New Trade") {
                    menuController.currentTradeButtonFunction = "NewTrade"
                    showNewTrade.toggle()
                }
                Button("Import Trades") {
                    menuController.currentTradeButtonFunction = "Import Trades"
                    showNinjaTraderImporter.toggle()
                }
            }else if menuController.currentTradeButtonFunction == "NewTrade"{
                Button("Import Orders") {
                    menuController.currentTradeButtonFunction = "Import Orders"
                    showFileImporter.toggle()
                }
                Button("Import Trades") {
                    menuController.currentTradeButtonFunction = "Import Trades"
                    showNinjaTraderImporter.toggle()
                }
            }else {
                Button("Import Orders") {
                    menuController.currentTradeButtonFunction = "Import Orders"
                    showFileImporter.toggle()
                }
                Button("New Trade") {
                    menuController.currentTradeButtonFunction = "NewTrade"
                    showNewTrade.toggle()
                }

            }
        }
    }

    private func handleNewTradeDismiss() {
        delayConfetti(sheetAction: sheetAction!, realmController: realmController)
    }

    private var gridItems: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 0, alignment: .center), count: 4)
    }

    private var leadingNavigationBarButton: some View {
        Button(action: toggleMenu) {
            if !showMenu {
                profileImage
            }
        }
    }

    private var profileImage: some View {
        Group {
            if UserDefaults.standard.bool(forKey: "personalDevice") {
                Image("Profile")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .foregroundColor(.green)
            }
        }
    }

    private var trailingNavigationBarButton: some View {
        Button {
            menuController.showAccout.toggle()
        } label: {
            Image(systemName: "chart.bar.fill")
        }
        .contextMenu {
            ForEach(realmController.accounts) { account in
                Button {
                    realmController.switchAccount(name: account.name)
                } label: {
                    Label(account.name, systemImage: realmController.account.name == account.name ? "checkmark" : "")
                }
            }
        }
        .foregroundColor(.green)
    }

    private func toggleMenu() {
        withAnimation {
            showMenu.toggle()
        }
    }

    private func delayConfetti(sheetAction: SheetAction, realmController: RealmController) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if sheetAction == .win {
                confettiCounter += 1
            }
            self.sheetAction = .nothing
        }
    }
    
    func handleNinjaTraderImoprt(_ result: Result<[URL], Error>) {
        do {
            let fileURLs = try result.get()
            var allTrades: [Trade] = []
            
            for fileURL in fileURLs {
                controller.processNinjaTraderFile(at: fileURL, into: &allTrades)
            }
            realmController.addNinjaTraderTrades(allTrades)
        } catch {
            print("Error reading files: \(error.localizedDescription)")
        }
    }

    func handleFileImport(_ result: Result<[URL], Error>) {
        do {
            let fileURLs = try result.get()
            var allOrders: [ImportOrder] = []
            
            for fileURL in fileURLs {
                processFile(at: fileURL, into: &allOrders)
            }
            
            processOrders(allOrders)
        } catch {
            print("Error reading files: \(error.localizedDescription)")
        }
    }

    private func processFile(at fileURL: URL, into orders: inout [ImportOrder]) {
        do {
            // Access security-scoped resource
            _ = fileURL.startAccessingSecurityScopedResource()
            defer { fileURL.stopAccessingSecurityScopedResource() }
            
            let fileContent = try String(contentsOf: fileURL, encoding: .utf8)
            let parsedCSV = parseCSV(fileContent)
            
            // Append valid ImportOrder entries to orders
            for row in parsedCSV.dropFirst().dropLast() {  // Drop first (header) and last (empty line)
                if let importOrder = createImportOrder(from: row) {
                    orders.append(importOrder)
                }
            }
        } catch {
            print("Error processing file \(fileURL): \(error.localizedDescription)")
        }
    }

    private func parseCSV(_ content: String) -> [[String]] {
        content.components(separatedBy: "\n").map { $0.components(separatedBy: ",") }
    }

    private func createImportOrder(from row: [String]) -> ImportOrder? {
//        guard row.count >= 29 else { return nil }  // Ensure valid row length
        
        if row.count >= 29 {
            return ImportOrder(
                orderId: row[0],
                account: row[1],
                orderID: row[2],
                bs: row[3],
                contract: row[4],
                product: row[5],
                productDescription: row[6],
                avgPrice: row[7],
                filledQty: row[8],
                fillTime: row[9],
                lastCommandId: row[10],
                status: row[11],
                priceFormat: row[12],
                priceFormatType: row[13],
                tickSize: row[14],
                spreadDefinitionId: row[15],
                versionId: row[16],
                timestamp: row[17],
                date: row[18],
                quantity: row[19],
                text: row[20],
                type: row[21],
                limitPrice: row[22],
                stopPrice: row[23],
                decimalLimit: row[24],
                decimalStop: row[25],
                filledQtyLabel: row[26],
                avgFillPrice: row[27],
                decimalFillAvg: row[28]
            )
        }else if row.count == 15 {
            return ImportOrder(
                orderId: row[5],
                account: row[12],
                orderID: row[5],
                bs: row[1],
                contract: row[0],
                product: row[0],
                productDescription: row[0],
                avgPrice: row[3],
                filledQty: row[2],
                fillTime: row[4],
                lastCommandId: "",
                status: row[1],
                priceFormat: "",
                priceFormatType: "",
                tickSize: "0.25",
                spreadDefinitionId: "",
                versionId: "",
                timestamp: row[4],
                date: "",
                quantity: row[2],
                text: "",
                type: "",
                limitPrice: "",
                stopPrice: "",
                decimalLimit: "",
                decimalStop: "",
                filledQtyLabel: "",
                avgFillPrice: row[3],
                decimalFillAvg: ""
            )
        }else {
            return ImportOrder(
                orderId: row[15],
                account: row[13],
                orderID: row[15],
                bs: row[1],
                contract: row[0],
                product: row[0],
                productDescription: row[0],
                avgPrice: row[8],
                filledQty: row[7],
                fillTime: row[17],
                lastCommandId: "",
                status: row[6],
                priceFormat: "",
                priceFormatType: "",
                tickSize: "0.25",
                spreadDefinitionId: "",
                versionId: "",
                timestamp: row[17],
                date: "",
                quantity: row[3],
                text: "",
                type: row[2],
                limitPrice: row[8],
                stopPrice: row[8],
                decimalLimit: row[5],
                decimalStop: row[6],
                filledQtyLabel: "",
                avgFillPrice: row[9],
                decimalFillAvg: ""
            )
        }
        
    }

    private func processOrders(_ orders: [ImportOrder]) {
        let debug: Bool = true
        var filteredOrders = orders.filter { !$0.status.contains("Rejected") }
        filteredOrders.sort { $0.account < $1.account }

        if orders[0].lastCommandId == "" {
            filteredOrders.sort {
                if $0.account == $1.account {
                    return $0.fillTime < $1.fillTime
                } else {
                    return $0.account < $1.account
                }
            }
        }
        
        if let firstIndex = filteredOrders.firstIndex(where: {$0.status.contains("Filled")}) {
            filteredOrders.removeSubrange(..<firstIndex)
        }
        
        if debug {
            for i in filteredOrders {
                print("Account: ", i.account, "\n\tStatus: ", i.status, "\n\tFill Time: ", i.fillTime, "\n")
            }
        }
        
        var trades: [(ImportOrder, [ImportOrder], [ImportOrder], ImportOrder?, ImportOrder?)] = []
        guard let firstOrder = filteredOrders.first else { return }
        
        var currentTrade = (firstOrder, [ImportOrder](), [ImportOrder](), nil as ImportOrder?, nil as ImportOrder?)
        var currentOpenContracts = Int(firstOrder.filledQty) ?? 0
        var activeTrade = true
        var activeTradeType: BuyOrSell = firstOrder.bs.contains("Buy") ? .buy : .sell
        
        for order in filteredOrders.dropFirst() {
            let tempType: BuyOrSell = order.bs.contains("Buy") ? .buy : .sell
            
            if order.status.contains("Canceled") && order.type.contains("Stop") && activeTrade {
                currentTrade.4 = order
            } else if order.status.contains("Filled") && !order.filledQty.isEmpty && activeTrade {
                handleFilledOrder(order, tempType: tempType, currentTrade: &currentTrade, currentOpenContracts: &currentOpenContracts, activeTrade: &activeTrade, activeTradeType: activeTradeType, trades: &trades)
            } else if !order.status.contains("Canceled") && !order.type.contains("Stop") && !activeTrade {
                // Start a new trade
                trades.append(currentTrade)
                currentTrade = (order, [], [], nil, nil)
                currentOpenContracts = Int(order.filledQty) ?? 0
                activeTradeType = order.bs.contains("Buy") ? .buy : .sell
                activeTrade.toggle()
            }
        }
        debug == true ? print("Trades: \(trades)") : nil
        // Append the last trade
        trades.append(currentTrade)
        
        // Save trades to the Realm database
        realmController.addImportOrders(orders: trades)
        sheetAction = .win
        delayConfetti(sheetAction: sheetAction!, realmController: realmController)
//        controller.updateAccountBalanceData(realmController: realmController)
    }

    private func handleFilledOrder(_ order: ImportOrder, tempType: BuyOrSell, currentTrade: inout (ImportOrder, [ImportOrder], [ImportOrder], ImportOrder?, ImportOrder?), currentOpenContracts: inout Int, activeTrade: inout Bool, activeTradeType: BuyOrSell, trades: inout [(ImportOrder, [ImportOrder], [ImportOrder], ImportOrder?, ImportOrder?)]) {
        if tempType == activeTradeType {
            currentTrade.1.append(order)
            currentOpenContracts += Int(order.filledQty) ?? 0
        } else if currentOpenContracts - (Int(order.filledQty) ?? 0) == 0 {
            if currentTrade.2.isEmpty {
                currentTrade.3 = order
            } else {
                currentTrade.2.append(order)
            }
            currentOpenContracts -= Int(order.filledQty) ?? 0
            activeTrade.toggle()
        } else if currentOpenContracts - (Int(order.filledQty) ?? 0) > 0 {
            currentTrade.2.append(order)
            currentOpenContracts -= Int(order.filledQty) ?? 0
        }
    }

}


////
////  ContentView.swift
////  TraderTracking
////
////  Created by Zach on 9/15/22.
////
//
//import SwiftUI
//import SwiftPieChart
//import RealmSwift
//import ConfettiSwiftUI
//import UniformTypeIdentifiers
//
//struct Dashboard: View {
//    @EnvironmentObject var realmController: RealmController
//    @EnvironmentObject var notifications: MyNotifications
//    @EnvironmentObject var menuController: MenuController
//    @EnvironmentObject var newsController: ForexCrawler
//    @StateObject var controller: DashBoardController = DashBoardController()
//    @State var showFileImporter = false
//    @State var csvData: String = ""
//    @State var sheetAction: SheetAction? = SheetAction.nothing
//    @State private var confettiCounter: Int = 0
//    @State private var showNewTrade = false
//    @State private var showImportOrders = false
//    @Binding var showMenu: Bool
//    @Binding var offSet: CGFloat
//
//    private let myFormatter = MyFormatter()
//    private let newTradeButtonWidth: CGFloat = 200
//    
//    
//    var stats = ["P&L", "# Trades", "%", "Avg RR"]
//
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                VStack{
////                    Divider()
////                    HStack{
////                        CountdownTimer()
////        //                LondonCountdownTimer()
////        //                AsiaCountdownTimer()
////                    }
//                    mainContent
//                }
//                
//                BlurBackground(showMenu: $showMenu, offSet: $offSet)
//                HiddenNavigationView()
//                    .environmentObject(menuController)
//                    .environmentObject(notifications)
//                    .environmentObject(realmController)
//                addButton
//            }
//            .navigationTitle("")
//            .navigationBarItems(leading: leadingNavigationBarButton, trailing: trailingNavigationBarButton)
//            .navigationDestination(isPresented: $menuController.showCalendarView) {
//                ScrollableMonthView()
//                    .environmentObject(realmController)
//            }
//        }
//        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
//    }
//    
//    private var mainContent: some View {
//        List{
////            TradeSchedule(tradeDays: controller.createTradeDaySchedule())
//            VStack(alignment: .center){
//                Text(realmController.account.name)
//                    .font(.title2)
//            }
//            
//            MonthView(currentMonthDate: Date(), trades: realmController.account.trades.filter("dateEntered BETWEEN {%@, %@} AND isDeleted = false", Date().startOfMonth(), Date().endOfMonth()), showCalendarView: $menuController.showCalendarView, showCurrentMonthOnly: true)
//            
//            Section{
//                Text("Monthly Stats")
//                    .bold()
//                VStack{
//                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(),spacing: 0, alignment: .center), count: 4), spacing: 5){
//                        ForEach(stats, id: \.self) { stat in
//                            Text(stat)
//                                .fontWeight(.bold)
//                        }
//                    }
//                    .listRowSeparator(.hidden)
//                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(),spacing: 0, alignment: .center), count: 4), spacing: 5){
//                        let monthlyTrades = realmController.account.trades.filter("dateEntered BETWEEN {%@, %@}  AND isDeleted = false", Date().startOfMonth(), Date().endOfMonth())
//                        ForEach(0...3, id: \.self) { i in
//                            switch i {
//                            case 0:
//                                let p_l: Decimal128 = monthlyTrades.sum(ofProperty: "p_l")
//                                let fees: Decimal128 = monthlyTrades.sum(ofProperty: "fees")
//                                Text(myFormatter.numFormat(num: p_l - fees))
//                            case 1:
//                                Text(String(monthlyTrades.count))
//                            case 2:
//                                let p_l: Decimal128 = monthlyTrades.sum(ofProperty: "p_l")
//                                let accountBalanceBefore = realmController.account.balance - p_l
//                                Text(String(myFormatter.percentFormat(num: Double(p_l.doubleValue / accountBalanceBefore.doubleValue))))
//                            case 3:
//                                let sumRR: Double = monthlyTrades.filter("riskToReward > 0").sum(ofProperty: "riskToReward")
//                                let RR: Double = Double( sumRR / Double(monthlyTrades.filter("riskToReward > 0").count))
//                                Text(String(format: "%.2f",RR))
//                            default:
//                                Text("")
//    }
//                        }
//                    }
//                    Spacer()
//                    HStack{
//                        Spacer()
//                        Text("Win Rate")
//                            .bold()
//                        Spacer()
//                    }
//                    HStack{
//                        WinRatePieChart(wins: Double(realmController.account.trades.filter("dateEntered BETWEEN {%@, %@} AND isDeleted = false AND win = true ", Date().startOfMonth(), Date().endOfMonth()).count),
//                                        losses: Double(realmController.account.trades.filter("dateEntered BETWEEN {%@, %@} AND isDeleted = false AND loss = true", Date().startOfMonth(), Date().endOfMonth()).count))
//                        Spacer()
//                    }
//                }
//
//            }
//
////            Spacer()
//            Section{
//
//
//            }
//            Section {
//                Text("Balance")
//                    .bold()
//                AccontBalanceLineChart(balance: $controller.accountBalanceData, yAxisRange: $controller.accountYAxis)
//                    .onAppear(perform: {
//                        controller.updateAccountBalanceData(realmController: realmController)
//                    })
//            }
//            
//        }
//        .frame(maxWidth: .infinity , maxHeight: .infinity)
//        .scrollIndicators(.hidden)
//    }
//
//    private var addButton: some View {
//        // Floating button at the bottom right
//        VStack {
//            Spacer()
//            HStack {
//                Spacer()
//                Button(action: {
//                    if menuController.currentTradeButtonFunction == "Import" {
//                        showFileImporter.toggle()
//                    }else{
//                        showNewTrade.toggle()
//                    }
//                }) {
//                    if menuController.currentTradeButtonFunction == "Import" {
//                        Image(systemName: "square.and.arrow.down")
//                            .padding()
//                            .background(Color.green)
//                            .foregroundColor(.white)
//                            .clipShape(Circle())
//                    }else{
//                        Image(systemName: "plus")
//                            .padding()
//                            .background(Color.green)
//                            .foregroundColor(.white)
//                            .clipShape(Circle())
//                    }
//                }
//                .confettiCannon(counter: $confettiCounter, num: 250, confettis: [.shape(.slimRectangle), .shape(.square)], colors: [.green], rainHeight: 700, openingAngle: Angle.degrees(35), closingAngle: Angle.degrees(145), radius: 400)
//                .sheet(isPresented: $showNewTrade, onDismiss: { delayConfetti(sheetAction: sheetAction!, realmController: realmController) }) {
//                    NewTradeView(sheetAction: $sheetAction, isEditing: false)
//                        .environmentObject(realmController)
//                        .environmentObject(newsController)
//                }
//                .fileImporter(
//                    isPresented: $showFileImporter,
//                    allowedContentTypes: [UTType.commaSeparatedText],
//                    allowsMultipleSelection: true,
//                    onCompletion: handleFileImport
//                )
//                .background(Color.clear)
//                // Context menu
//                .contentShape(.contextMenuPreview, Circle())
//                .contextMenu {
//                    if menuController.currentTradeButtonFunction == "Import" {
//                        Button("New Trade") {
//                            menuController.currentTradeButtonFunction = "NewTrade"
//                            showNewTrade.toggle()
//                        }
//                    }else{
//                        Button("Import Orders") {
//                            menuController.currentTradeButtonFunction = "Import"
//                            showFileImporter.toggle()
//                        }
//                    }
//                }
//                
//                .padding()
//            }
//        }
//    }
//
//    private var winRateText: some View {
//        Text(realmController.winRate)
//            .onAppear(perform: realmController.getWinRate)
//            .font(.largeTitle)
//            .padding()
//    }
//    
//    private var monthlyWinsAndLosses: some View {
//        HStack {
//            Spacer()
//            VStack {
//                Text("Wins")
//                Text(String(weeklyWins))
//            }
//            .foregroundColor(Color(UIColor.label))
//            Spacer()
//            VStack {
//                Text("Losses")
//                Text(String(weeklyLosses))
//            }
//            .foregroundColor(Color(UIColor.label))
//            Spacer()
//        }
//        .padding()
//    }
//    
//    private var newTradeButton: some View {
//        VStack {
//            Button(action: { showNewTrade.toggle() }) {
//                Text("New Trade")
//                    .frame(minWidth: 0, maxWidth: newTradeButtonWidth)
//                    .font(.system(size: 18))
//                    .padding()
//                    .foregroundColor(.white)
//                    .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.green, lineWidth: 2))
//            }
//            .background(Color.green)
//            .cornerRadius(25)
//            .confettiCannon(counter: $confettiCounter, num: 250, confettis: [.shape(.slimRectangle), .shape(.square)], colors: [.green], rainHeight: 700, openingAngle: Angle.degrees(35), closingAngle: Angle.degrees(145), radius: 400)
//            .sheet(isPresented: $showNewTrade, onDismiss: { delayConfetti(sheetAction: sheetAction!, realmController: realmController) }) {
//                NewTradeView(sheetAction: $sheetAction, isEditing: false)
//                    .environmentObject(realmController)
//                    .environmentObject(newsController)
//            }
//        }
//        .padding()
//    }
//    
//    private var importOrdersButton: some View {
//        VStack {
//            Button(action: { showFileImporter.toggle() }) {
//                Text("Import Orders")
//                    .frame(minWidth: 0, maxWidth: newTradeButtonWidth)
//                    .font(.system(size: 18))
//                    .padding()
//                    .foregroundColor(.white)
//                    .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.green, lineWidth: 2))
//            }
//            .background(Color.green)
//            .cornerRadius(25)
//            .confettiCannon(counter: $confettiCounter, num: 250, confettis: [.shape(.slimRectangle), .shape(.square)], colors: [.green], rainHeight: 700, openingAngle: Angle.degrees(35), closingAngle: Angle.degrees(145), radius: 400)
//            .fileImporter(
//                isPresented: $showFileImporter,
//                allowedContentTypes: [UTType.commaSeparatedText],
//                allowsMultipleSelection: true,
//                onCompletion: handleFileImport
//            )
//        }
//        .padding()
//    }
//    
//    private var weeklyWins: Int {
//        realmController.account.trades.filter("dateEntered BETWEEN {%@, %@} AND win = true AND isHindsight = false AND isDeleted = false",Date().startOfMonth(), Date().endOfMonth()).count
//    }
//
//    private var weeklyLosses: Int {
//        realmController.account.trades.filter("dateEntered BETWEEN {%@, %@} AND loss = true AND isHindsight = false AND isDeleted = false", Date().startOfMonth(), Date().endOfMonth()).count
//    }
//
//    private var leadingNavigationBarButton: some View {
//        Button(action: {
//            withAnimation {
//                showMenu.toggle()
//            }
//        }) {
//            if !showMenu {
//                if UserDefaults.standard.bool(forKey: "personalDevice") {
//                    Image("Profile")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 40, height: 40)
//                        .clipShape(Circle())
//                } else {
//                    Image(systemName: "person.crop.circle.fill")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 30, height: 30)
//                        .clipShape(Circle())
//                        .foregroundColor(.green)
//                }
//            }
//        }
//    }
//
//    private var trailingNavigationBarButton: some View {
//        Button {
//            menuController.showAccout.toggle()
//        } label: {
//            Image(systemName: "chart.bar.fill")
//        }
//        .contextMenu{
//            ForEach(realmController.accounts){ a in
//                Button {
//                    realmController.switchAccount(name: a.name)
//                } label: {
//                    if realmController.account.name == a.name{
//                        Label(a.name, systemImage: "checkmark")
//                    }else{
//                        Text(a.name)
//                    }
//                }
//            }
//        }
//        .foregroundColor(.green)
//    }
//
//    private func delayConfetti(sheetAction: SheetAction, realmController: RealmController) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            switch sheetAction {
//            case .nothing, .loss, .cancel:
//                break
//            case .win:
//                confettiCounter += 1
//            case .done:
//                break
//            }
//            self.sheetAction = .nothing
//        }
//    }
//    func handleFileImport(_ result: Result<[URL], Error>) {
//        // Handle the result of the file impor
//        var orders: [ImportOrder] = []
//        do {
//            for i in try result.get(){
//                // Read the file content
//                _ = i.startAccessingSecurityScopedResource()
//                let test = try String(contentsOf: i, encoding: .utf8)
//                let parsedCSV: [[String]] = test.components(
//                            separatedBy: "\n"
//                    ).map{ $0.components(separatedBy: ",") }
//    
//                let lines = csvData.components(separatedBy: "")
//                // Here you can parse the CSV data
//                //["orderId", "Account", "Order ID", "B/S", "Contract", "Product", "Product Description", "avgPrice", "filledQty", "Fill Time", "lastCommandId", "Status", "_priceFormat", "_priceFormatType", "_tickSize", "spreadDefinitionId", "Version ID", "Timestamp", "Date", "Quantity", "Text", "Type", "Limit Price", "Stop Price", "decimalLimit", "decimalStop", "Filled Qty", "Avg Fill Price", "decimalFillAvg"]
//                for l in 1...parsedCSV.count - 2{
//                    orders.append(ImportOrder(orderId: String(parsedCSV[l][0]), account: String(parsedCSV[l][1]), orderID: String(parsedCSV[l][2]), bs: String(parsedCSV[l][3]), contract: String(parsedCSV[l][4]), product: String(parsedCSV[l][5]), productDescription: String(parsedCSV[l][6]), avgPrice: String(parsedCSV[l][7]), filledQty: String(parsedCSV[l][8]), fillTime: String(parsedCSV[l][9]), lastCommandId: String(parsedCSV[l][10]), status: String(parsedCSV[l][11]), priceFormat: String(parsedCSV[l][12]), priceFormatType: String(parsedCSV[l][13]), tickSize: String(parsedCSV[l][14]), spreadDefinitionId: String(parsedCSV[l][15]), versionId: String(parsedCSV[l][16]), timestamp: String(parsedCSV[l][17]), date: String(parsedCSV[l][18]), quantity: String(parsedCSV[l][19]), text: String(parsedCSV[l][20]), type: String(parsedCSV[l][21]), limitPrice: String(parsedCSV[l][22]), stopPrice: String(parsedCSV[l][23]), decimalLimit: String(parsedCSV[l][24]), decimalStop: String(parsedCSV[l][25]), filledQtyLabel: String(parsedCSV[l][26]), avgFillPrice: String(parsedCSV[l][27]), decimalFillAvg: String(parsedCSV[l][28])))
//                }
//                if let firstIndex = orders.firstIndex(where: {$0.status == " Filled"}) {
//                    orders.removeSubrange(..<firstIndex)
//                }
//                orders.removeAll(where: {$0.status == " Rejected"})
//                orders.removeAll(where: {$0.status == " Canceled" && $0.type != " Stop"})
//                orders.sort {$0.timestamp < $1.timestamp}
//    
//    
//                // (First Order, Prymiad, Partials, Full Exit if no partials, Stop Loss Order)
//                var trades: [(ImportOrder, [ImportOrder], [ImportOrder], ImportOrder?, ImportOrder?)] = []
//                trades.append((orders[0],[],[],nil,nil))
//                var firstOrder = orders[0]
//                var currentOpenContracts = Int(orders[0].filledQty) ?? 0
//                var activeTrade: Bool = true
//                var activeTradeType: BuyOrSell = orders[0].bs == " Buy" ? .buy : .sell
//    
//                for i in 1...orders.count - 1 {
//                    var tempType: BuyOrSell = orders[i].bs == " Buy" ? .buy : .sell
//    
//                    if orders[i].status == " Canceled" && orders[i].type == " Stop" && activeTrade{
//                        trades[trades.firstIndex(where: {$0.0.orderId == firstOrder.orderId})!].4 = orders[i]
//                    }else if orders[i].status == " Filled" && orders[i].filledQty != "" && activeTrade{
//                        // Handle Partials
//                        if tempType == activeTradeType && orders[i].status == " Filled" {
//                            trades[trades.firstIndex(where: {$0.0.orderId == firstOrder.orderId})!].1.append(orders[i])
//                            currentOpenContracts += Int(orders[i].filledQty)!
//                        }else if currentOpenContracts - Int(orders[i].filledQty)! == 0 {
//                            if trades[trades.firstIndex(where: {$0.0.orderId == firstOrder.orderId})!].2.count > 0 {
//                                trades[trades.firstIndex(where: {$0.0.orderId == firstOrder.orderId})!].2.append(orders[i])
//                                currentOpenContracts -= Int(orders[i].filledQty)!
//                                activeTrade.toggle()
//                            }else{
//                                trades[trades.firstIndex(where: {$0.0.orderId == firstOrder.orderId})!].3 = orders[i]
//                                currentOpenContracts -= Int(orders[i].filledQty)!
//                                activeTrade.toggle()
//                            }
//                        }else if currentOpenContracts - Int(orders[i].filledQty)! > 0{
//                            trades[trades.firstIndex(where: {$0.0.orderId == firstOrder.orderId})!].2.append(orders[i])
//                            currentOpenContracts -= Int(orders[i].filledQty)!
//                        }
//                    }else if orders[i].status != " Canceled" && orders[i].type != " Stop" && !activeTrade{
//    //                    print("New Trade", orders[i].avgFillPrice)
//                        trades.append((orders[i],[],[],nil,nil))
//                        firstOrder = orders[i]
//                        currentOpenContracts = Int(firstOrder.filledQty)!
//                        activeTradeType = orders[i].bs == " Buy" ? .buy : .sell
//                        activeTrade.toggle()
//                    }
//    //                print(orders[i].orderId,orders[i].status, orders[i].type, currentOpenContracts, activeTrade )
//    
//    //                print(trades[trades.firstIndex(where: {$0.0.orderId == firstOrder.orderId})!].0)
//    //                print(trades[trades.firstIndex(where: {$0.0.orderId == firstOrder.orderId})!].1)
//    //                print(trades[trades.firstIndex(where: {$0.0.orderId == firstOrder.orderId})!].2)
//    //                print(trades[trades.firstIndex(where: {$0.0.orderId == firstOrder.orderId})!].3)
//    //                print(trades[trades.firstIndex(where: {$0.0.orderId == firstOrder.orderId})!].4)
//                }
//    
//    
//    
//    
//                //this does not handle order pyrimidaing. Only handlind partils from a single entry
//    //            for i in 1...orders.count - 1{
//    //                print(orders[i].orderId)
//    //                if orders[i].filledQty != firstOrder.filledQty && orders[i].bs != firstOrder.bs && orders[i].orderId != firstOrder.orderId{
//    //                    trades[trades.firstIndex(where: {$0.0.orderId == firstOrder.orderId})!].1.append(orders[i])
//    //                }else if orders[i].filledQty == firstOrder.filledQty && orders[i].bs != firstOrder.bs && orders[i].orderId != firstOrder.orderId{
//    //                    trades[trades.firstIndex(where: {$0.0.orderId == firstOrder.orderId})!].2 = orders[i]
//    //
//    //                    firstOrder = i + 1 != orders.count ? orders[i + 1] : orders[i]
//    //                }else{
//    //                    trades.append((orders[i],[],nil))
//    //                    firstOrder = orders[i]
//    //                }
//    //            }
//                realmController.addImportOrders(orders: trades)
//                sheetAction = .win
//                delayConfetti(sheetAction: sheetAction!, realmController: realmController)
//                controller.updateAccountBalanceData(realmController: realmController)
//            }
//
//        } catch {
//            // Handle error
//            print("Error reading file: \(error.localizedDescription)")
//        }
//    }
//    
//
//}
enum BuyOrSell{
    case buy
    case sell
}

enum SheetAction {
    case nothing
    case loss
    case win
    case cancel
    case done
}
//
//struct SmallProfileView: View {
//    var body: some View {
//        if UserDefaults.standard.bool(forKey: "personalDevice"){
//            Image("Profile")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 40, height: 40)
//                .clipShape(Circle())
//
//        }else{
//            Image(systemName: "person.crop.circle.fill")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 30, height: 30)
//                .clipShape(Circle())
//                .foregroundColor(.green)
//        }
//    }
//}
//
struct BlurBackground: View {
    @Binding var showMenu: Bool
    @Binding var offSet: CGFloat
    var screenWidth = UIScreen.main.bounds.width
    
    @Environment(\.colorScheme) var scheme
    var body: some View {
        withAnimation{
            (scheme == .light ? Color.black : Color.white).opacity(0.3)
                .opacity(offSet > 0 ? ((offSet-50)/screenWidth) : 0)
                .ignoresSafeArea()
                .allowsHitTesting(offSet > 0 ? true : false)
                .onTapGesture {
                    withAnimation {
                        showMenu.toggle()
                    }
                }
        }

    }
}
//
//
////struct DashboardView_Previews: PreviewProvider {
////    static var previews: some View {
////        
////        Dashboard(showMenu: <#Binding<Bool>#>, offSet: <#Binding<CGFloat>#>)
////    }
////}

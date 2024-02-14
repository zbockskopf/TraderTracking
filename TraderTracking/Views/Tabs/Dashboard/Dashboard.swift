//
//  ContentView.swift
//  TraderTracking
//
//  Created by Zach on 9/15/22.
//

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
    @State var showFileImporter = false
    @State var csvData: String = ""
    @State var sheetAction: SheetAction? = SheetAction.nothing
    @State private var confettiCounter: Int = 0
    @State private var showNewTrade = false
    @State private var showImportOrders = false
    @Binding var showMenu: Bool
    @Binding var offSet: CGFloat

    private let myFormatter = MyFormatter()
    private let newTradeButtonWidth: CGFloat = 200
    
    
    var stats = ["P&L", "# Trades", "%", "Avg RR"]

    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack{
//                    Divider()
                    HStack{
                        CountdownTimer()
        //                LondonCountdownTimer()
        //                AsiaCountdownTimer()
                    }
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
            .navigationDestination(isPresented: $menuController.showCalendarView) {
                ScrollableMonthView()
                    .environmentObject(realmController)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
    
    private var mainContent: some View {
        List{
//            TradeSchedule(tradeDays: controller.createTradeDaySchedule())
            VStack{
                Text(realmController.account.name)
                    .font(.title2)
            }
            
            MonthView(currentMonthDate: Date(), trades: realmController.account.trades.filter("dateEntered BETWEEN {%@, %@} AND isDeleted = false", Date().startOfMonth(), Date().endOfMonth()), showCalendarView: $menuController.showCalendarView, showCurrentMonthOnly: true)
            Section{
                VStack{
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(),spacing: 0, alignment: .center), count: 4), spacing: 5){
                        ForEach(stats, id: \.self) { stat in
                            Text(stat)
                                .fontWeight(.bold)
                        }
                    }
                    .listRowSeparator(.hidden)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(),spacing: 0, alignment: .center), count: 4), spacing: 5){
                        let monthlyTrades = realmController.account.trades.filter("dateEntered BETWEEN {%@, %@}  AND isDeleted = false", Date().startOfMonth(), Date().endOfMonth())
                        ForEach(0...3, id: \.self) { i in
                            switch i {
                            case 0:
                                let p_l: Decimal128 = monthlyTrades.sum(ofProperty: "p_l")
                                let fees: Decimal128 = monthlyTrades.sum(ofProperty: "fees")
                                Text(myFormatter.numFormat(num: p_l - fees))
                            case 1:
                                Text(String(monthlyTrades.count))
                            case 2:
                                let p_l: Decimal128 = monthlyTrades.sum(ofProperty: "p_l")
                                let accountBalanceBefore = realmController.account.balance - p_l
                                Text(String(myFormatter.percentFormat(num: Double(p_l.doubleValue / accountBalanceBefore.doubleValue))))
                            case 3:
                                let sumRR: Double = monthlyTrades.filter("riskToReward > 0").sum(ofProperty: "riskToReward")
                                let RR: Double = Double( sumRR / Double(monthlyTrades.filter("riskToReward > 0").count))
                                Text(String(format: "%.2f",RR))
                            default:
                                Text("")
    }
                        }
                    }
                }
            }

//            Spacer()
            Section{
                Text("Win Rate")
                    .bold()
                HStack{
                    WinRatePieChart(wins: Double(realmController.wins.filter("dateEntered BETWEEN {%@, %@} AND isDeleted = false", Date().startOfMonth(), Date().endOfMonth()).count),
                                    losses: Double(realmController.losses.filter("dateEntered BETWEEN {%@, %@} AND isDeleted = false", Date().startOfMonth(), Date().endOfMonth()).count))
                    Spacer()
                }

            }
            Section {
                Text("Balance")
                    .bold()
                AccontBalanceLineChart(balance: $controller.accountBalanceData, yAxisRange: $controller.accountYAxis)
                    .onAppear(perform: {
                        controller.updateAccountBalanceData(realmController: realmController)
                    })
            }
            
        }
        .frame(maxWidth: .infinity , maxHeight: .infinity)
        .scrollIndicators(.hidden)
    }

    private var addButton: some View {
        // Floating button at the bottom right
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    if menuController.currentTradeButtonFunction == "Import" {
                        showFileImporter.toggle()
                    }else{
                        showNewTrade.toggle()
                    }
                }) {
                    if menuController.currentTradeButtonFunction == "Import" {
                        Image(systemName: "square.and.arrow.down")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }else{
                        Image(systemName: "plus")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                }
                .confettiCannon(counter: $confettiCounter, num: 250, confettis: [.shape(.slimRectangle), .shape(.square)], colors: [.green], rainHeight: 700, openingAngle: Angle.degrees(35), closingAngle: Angle.degrees(145), radius: 400)
                .sheet(isPresented: $showNewTrade, onDismiss: { delayConfetti(sheetAction: sheetAction!, realmController: realmController) }) {
                    NewTradeView(sheetAction: $sheetAction, isEditing: false)
                        .environmentObject(realmController)
                        .environmentObject(newsController)
                }
                .fileImporter(
                    isPresented: $showFileImporter,
                    allowedContentTypes: [UTType.commaSeparatedText],
                    onCompletion: handleFileImport
                )
                .background(Color.clear)
                // Context menu
                .contentShape(.contextMenuPreview, Circle())
                .contextMenu {
                    if menuController.currentTradeButtonFunction == "Import" {
                        Button("New Trade") {
                            menuController.currentTradeButtonFunction = "NewTrade"
                            showNewTrade.toggle()
                        }
                    }else{
                        Button("Import Orders") {
                            menuController.currentTradeButtonFunction = "Import"
                            showFileImporter.toggle()
                        }
                    }
                }
                
                .padding()
            }
        }
    }

    private var winRateText: some View {
        Text(realmController.winRate)
            .onAppear(perform: realmController.getWinRate)
            .font(.largeTitle)
            .padding()
    }
    
    private var monthlyWinsAndLosses: some View {
        HStack {
            Spacer()
            VStack {
                Text("Wins")
                Text(String(weeklyWins))
            }
            .foregroundColor(Color(UIColor.label))
            Spacer()
            VStack {
                Text("Losses")
                Text(String(weeklyLosses))
            }
            .foregroundColor(Color(UIColor.label))
            Spacer()
        }
        .padding()
    }
    
    private var newTradeButton: some View {
        VStack {
            Button(action: { showNewTrade.toggle() }) {
                Text("New Trade")
                    .frame(minWidth: 0, maxWidth: newTradeButtonWidth)
                    .font(.system(size: 18))
                    .padding()
                    .foregroundColor(.white)
                    .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.green, lineWidth: 2))
            }
            .background(Color.green)
            .cornerRadius(25)
            .confettiCannon(counter: $confettiCounter, num: 250, confettis: [.shape(.slimRectangle), .shape(.square)], colors: [.green], rainHeight: 700, openingAngle: Angle.degrees(35), closingAngle: Angle.degrees(145), radius: 400)
            .sheet(isPresented: $showNewTrade, onDismiss: { delayConfetti(sheetAction: sheetAction!, realmController: realmController) }) {
                NewTradeView(sheetAction: $sheetAction, isEditing: false)
                    .environmentObject(realmController)
                    .environmentObject(newsController)
            }
        }
        .padding()
    }
    
    private var importOrdersButton: some View {
        VStack {
            Button(action: { showFileImporter.toggle() }) {
                Text("Import Orders")
                    .frame(minWidth: 0, maxWidth: newTradeButtonWidth)
                    .font(.system(size: 18))
                    .padding()
                    .foregroundColor(.white)
                    .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.green, lineWidth: 2))
            }
            .background(Color.green)
            .cornerRadius(25)
            .confettiCannon(counter: $confettiCounter, num: 250, confettis: [.shape(.slimRectangle), .shape(.square)], colors: [.green], rainHeight: 700, openingAngle: Angle.degrees(35), closingAngle: Angle.degrees(145), radius: 400)
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [UTType.commaSeparatedText],
                onCompletion: handleFileImport
            )
        }
        .padding()
    }
    
    private var weeklyWins: Int {
        realmController.account.trades.filter("dateEntered BETWEEN {%@, %@} AND win = true AND isHindsight = false AND isDeleted = false",Date().startOfMonth(), Date().endOfMonth()).count
    }

    private var weeklyLosses: Int {
        realmController.account.trades.filter("dateEntered BETWEEN {%@, %@} AND loss = true AND isHindsight = false AND isDeleted = false", Date().startOfMonth(), Date().endOfMonth()).count
    }

    private var leadingNavigationBarButton: some View {
        Button(action: {
            withAnimation {
                showMenu.toggle()
            }
        }) {
            if !showMenu {
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
    }

    private var trailingNavigationBarButton: some View {
        Button {
            menuController.showAccout.toggle()
        } label: {
            Image(systemName: "chart.bar.fill")
        }
        .foregroundColor(.green)
    }

    private func delayConfetti(sheetAction: SheetAction, realmController: RealmController) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            switch sheetAction {
            case .nothing, .loss, .cancel:
                break
            case .win:
                confettiCounter += 1
            case .done:
                break
            }
            self.sheetAction = .nothing
        }
    }
    func handleFileImport(_ result: Result<URL, Error>) {
        // Handle the result of the file impor
        var orders: [ImportOrder] = []
        do {
            
            let fileURL = try result.get()
            // Read the file content
            fileURL.startAccessingSecurityScopedResource()
            let test = try String(contentsOf: fileURL, encoding: .utf8)
            let parsedCSV: [[String]] = test.components(
                        separatedBy: "\n"
                ).map{ $0.components(separatedBy: ",") }
            
            let lines = csvData.components(separatedBy: "")
            // Here you can parse the CSV data
            //["orderId", "Account", "Order ID", "B/S", "Contract", "Product", "Product Description", "avgPrice", "filledQty", "Fill Time", "lastCommandId", "Status", "_priceFormat", "_priceFormatType", "_tickSize", "spreadDefinitionId", "Version ID", "Timestamp", "Date", "Quantity", "Text", "Type", "Limit Price", "Stop Price", "decimalLimit", "decimalStop", "Filled Qty", "Avg Fill Price", "decimalFillAvg"]
            for l in 1...parsedCSV.count - 2{
                orders.append(ImportOrder(orderId: String(parsedCSV[l][0]), account: String(parsedCSV[l][1]), orderID: String(parsedCSV[l][2]), bs: String(parsedCSV[l][3]), contract: String(parsedCSV[l][4]), product: String(parsedCSV[l][5]), productDescription: String(parsedCSV[l][6]), avgPrice: String(parsedCSV[l][7]), filledQty: String(parsedCSV[l][8]), fillTime: String(parsedCSV[l][9]), lastCommandId: String(parsedCSV[l][10]), status: String(parsedCSV[l][11]), priceFormat: String(parsedCSV[l][12]), priceFormatType: String(parsedCSV[l][13]), tickSize: String(parsedCSV[l][14]), spreadDefinitionId: String(parsedCSV[l][15]), versionId: String(parsedCSV[l][16]), timestamp: String(parsedCSV[l][17]), date: String(parsedCSV[l][18]), quantity: String(parsedCSV[l][19]), text: String(parsedCSV[l][20]), type: String(parsedCSV[l][21]), limitPrice: String(parsedCSV[l][22]), stopPrice: String(parsedCSV[l][23]), decimalLimit: String(parsedCSV[l][24]), decimalStop: String(parsedCSV[l][25]), filledQtyLabel: String(parsedCSV[l][26]), avgFillPrice: String(parsedCSV[l][27]), decimalFillAvg: String(parsedCSV[l][28])))
            }
            orders.removeAll(where: {$0.status == " Canceled" && $0.type != " Stop"})
            orders.sort {$0.timestamp < $1.timestamp}
            // (First Order, Parrtials, Full Exit if no partials, Stop Loss Order)
            var trades: [(ImportOrder, [ImportOrder], ImportOrder?, ImportOrder?)] = []
            trades.append((orders[0],[],nil,nil))
            var firstOrder = orders[0]
            var currentOpenContracts = Int(orders[0].filledQty)!
            var activeTrade: Bool = true
            
            for i in 1...orders.count - 1 {
                print(orders[i].orderId)
                if orders[i].status == " Canceled" && orders[i].type == " Stop" && activeTrade{
                    trades[trades.firstIndex(where: {$0.0.orderId == firstOrder.orderId})!].3 = orders[i]
                }else if orders[i].status == " Filled" && orders[i].filledQty != ""{
                    if currentOpenContracts - Int(orders[i].filledQty)! == 0 {
                        if trades[trades.firstIndex(where: {$0.0.orderId == firstOrder.orderId})!].1.count > 0 {
                            trades[trades.firstIndex(where: {$0.0.orderId == firstOrder.orderId})!].1.append(orders[i])
                            currentOpenContracts -= Int(orders[i].filledQty)!
                            activeTrade.toggle()
                        }else{
                            trades[trades.firstIndex(where: {$0.0.orderId == firstOrder.orderId})!].2 = orders[i]
                            currentOpenContracts -= Int(orders[i].filledQty)!
                            activeTrade.toggle()
                        }
                        
                    }else if currentOpenContracts - Int(orders[i].filledQty)! > 0{
                        trades[trades.firstIndex(where: {$0.0.orderId == firstOrder.orderId})!].1.append(orders[i])
                        currentOpenContracts -= Int(orders[i].filledQty)!
                    }else{
                        trades.append((orders[i],[],nil,nil))
                        firstOrder = orders[i]
                        currentOpenContracts = Int(firstOrder.filledQty)!
                        activeTrade.toggle()
                    }
                }
            }
            
            
            //this does not handle order pyrimidaing. Only handlind partils from a single entry
//            for i in 1...orders.count - 1{
//                print(orders[i].orderId)
//                if orders[i].filledQty != firstOrder.filledQty && orders[i].bs != firstOrder.bs && orders[i].orderId != firstOrder.orderId{
//                    trades[trades.firstIndex(where: {$0.0.orderId == firstOrder.orderId})!].1.append(orders[i])
//                }else if orders[i].filledQty == firstOrder.filledQty && orders[i].bs != firstOrder.bs && orders[i].orderId != firstOrder.orderId{
//                    trades[trades.firstIndex(where: {$0.0.orderId == firstOrder.orderId})!].2 = orders[i]
//
//                    firstOrder = i + 1 != orders.count ? orders[i + 1] : orders[i]
//                }else{
//                    trades.append((orders[i],[],nil))
//                    firstOrder = orders[i]
//                }
//            }

            realmController.addImportOrders(orders: trades)
            sheetAction = .win
            delayConfetti(sheetAction: sheetAction!, realmController: realmController)
            controller.updateAccountBalanceData(realmController: realmController)
        } catch {
            // Handle error
            print("Error reading file: \(error.localizedDescription)")
        }
    }
    

}

enum SheetAction {
    case nothing
    case loss
    case win
    case cancel
    case done
}

struct SmallProfileView: View {
    var body: some View {
        if UserDefaults.standard.bool(forKey: "personalDevice"){
            Image("Profile")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .clipShape(Circle())

        }else{
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .clipShape(Circle())
                .foregroundColor(.green)
        }
    }
}

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


//struct DashboardView_Previews: PreviewProvider {
//    static var previews: some View {
//        
//        Dashboard(showMenu: <#Binding<Bool>#>, offSet: <#Binding<CGFloat>#>)
//    }
//}

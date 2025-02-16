//
//  ProfileView.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 9/29/22.
//

import SwiftUI
import RealmSwift
import Accelerate
import PagerTabStripView
//import ElegantCalendar


// MARK: - AccountView
struct AccountView: View {
    @EnvironmentObject var realmController: RealmController
    @EnvironmentObject var menuController: MenuController
    
    @State private var newAccountvalue: String = ""
    @State private var resetAccountAlert: Bool = false
    @State private var newBalanceValue: String = ""
    @State private var resetBalanceAlert: Bool = false
    @State private var showTodayPLandFees: Bool = false
    @State private var newAccountSheet: Bool = false
    @State
    
    var date = Date()
    var body: some View {
        // Top Profile Banner
        VStack(alignment: .leading){
//                        Image("Profile")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 55, height: 55)
//                            .clipShape(Circle())
//                            .padding(.bottom, 20)
                    
        // MARK: - Account Summary
            List{
                Section(header: Text(realmController.account.name)) {
                    AccountItemView(name: "Balance", value: realmController.account.balance)
                        .onTapGesture {
                            resetBalanceAlert.toggle()
                        }
                        .alert("Reset Balance", isPresented: $resetBalanceAlert, actions: {
                            TextField("New Value", text: $newBalanceValue)
                                .keyboardType(.decimalPad)
                            
                            Button("Reset", role: .destructive ,action: {
                                realmController.resetBalance(newVal: newBalanceValue)
                            })
                                .foregroundColor(.red)
                            Button("Cancel", role: .cancel, action:{})
                        }, message: {
                            Text("add new value")
                        })
                    AccountItemView(name: "P/L", value: (realmController.account.profitAndLoss - realmController.account.fees))
                    AccountItemView(name: "Fees", value: realmController.account.fees)
                }
                
                // MARK: - Today Stats
                
                Section(header: Text("Today Stats")){
                    AccountItemView(name: true ? "P/L" : "P/L", value: {
                        var temp: Decimal128 = 0.0
                        for i in realmController.account.trades.filter("dateEntered > %@ AND isHindsight = false  AND isDeleted = false", Calendar.current.startOfDay(for: date)) {
                                temp += i.p_l
//                            if showTodayPLandFees {
                                temp -= i.fees
//                            }
                        }
                        return temp
                    }())
                    .onTapGesture {
                        showTodayPLandFees.toggle()
                    }
                    AccountItemView(name: true ? "P/L% + fees" : "P/L%", value: {
                        var temp: Double = 0.0
                        for i in realmController.account.trades.filter("dateEntered > %@ AND isHindsight = false  AND isDeleted = false", Calendar.current.startOfDay(for: date)) {
                            temp += Double(i.p_l.stringValue) ?? 0.0
//                            if showTodayPLandFees {
                                temp -= Double(i.fees.stringValue) ?? 0.0
//                            }
                        }
                        return Decimal128(floatLiteral: temp) / (realmController.account.balance + Decimal128(floatLiteral: -temp))
                    }(), isPercent: true)
                    AccountItemView(name: "Average RR", value: {
                        var rrList: [Double] = []
                        for i in realmController.account.trades.filter("dateEntered > %@ AND isHindsight = false  AND isDeleted = false", Calendar.current.startOfDay(for: date)) {
                            if i.riskToReward > 0 {
                                rrList.append(i.riskToReward)
                            }
                            
                        }
                        let num = ((vDSP.mean(rrList) * 100).rounded() / 100).isNaN ? 0.0 : (vDSP.mean(rrList) * 100).rounded() / 100
                        return Decimal128(floatLiteral: num)
                    }(), isInt: true)
                    AccountItemView(name: "# of Trades", value: Decimal128(value: realmController.account.trades.filter("dateEntered > %@ AND isHindsight = false AND isDeleted = false", Calendar.current.startOfDay(for: date)).count), isInt: true)
                }
                
                // MARK: - Weekly Stats
                
                Section(header: Text("Weekly Stats")){
                    AccountItemView(name: "P/L", value: {
                        var temp: Decimal128 = 0.0
                        for i in realmController.account.trades.filter("dateEntered BETWEEN {%@, %@} AND isHindsight = false AND isDeleted = false", date.currentWeekdays.first!, date) {
                                temp += i.p_l
                                temp -= i.fees
                        }
                        return temp
                    }())
                    AccountItemView(name: "P/L%", value: {
                        var temp: Double = 0.0
                        for i in realmController.account.trades.filter("dateEntered BETWEEN {%@, %@} AND isHindsight = false AND isDeleted = false", date.currentWeekdays.first!, date)  {
                            temp += Double(i.p_l.stringValue) ?? 0.0
                            temp -= Double(i.fees.stringValue) ?? 0.0
                        }
                        return Decimal128(floatLiteral: temp) / (realmController.account.balance + Decimal128(floatLiteral: -temp))
                    }(), isPercent: true)
                    AccountItemView(name: "Average RR", value: {
                        var rrList: [Double] = []
                        for i in realmController.account.trades.filter("dateEntered BETWEEN {%@, %@} AND win = true AND isHindsight = false AND isDeleted = false", date.currentWeekdays.first!, date) {
                            if i.riskToReward > 0 {
                                rrList.append(i.riskToReward)
                            }
                        }
                        let num = ((vDSP.mean(rrList) * 100).rounded() / 100).isNaN ? 0.0 : (vDSP.mean(rrList) * 100).rounded() / 100
                        return Decimal128(floatLiteral: num)
                    }(), isInt: true)
                    AccountItemView(name: "# of Trades", value: Decimal128(value: realmController.account.trades.filter("dateEntered BETWEEN {%@, %@} AND isHindsight = false AND isDeleted = false", date.currentWeekdays.first!, date).count), isInt: true)
                }
                
                // MARK: - Monthly Stats
                
                Section(header: Text("Monthly Stats")){
                    AccountItemView(name: "P/L", value: {
                        var temp: Decimal128 = 0.0
                        for i in realmController.account.trades.filter("dateEntered BETWEEN {%@, %@} AND isHindsight = false AND isDeleted = false",  date.startOfMonth(), date.endOfMonth()) {
                                temp += i.p_l
                                temp -= i.fees
                        }
                        return temp
                    }())
                    AccountItemView(name: "P/L%", value: {
                        var temp: Double = 0.0
                        for i in realmController.account.trades.filter("dateEntered BETWEEN {%@, %@} AND isHindsight = false AND isDeleted = false", date.startOfMonth(), date.endOfMonth())  {
                            temp += Double(i.p_l.stringValue) ?? 0.0
                            temp -= Double(i.fees.stringValue) ?? 0.0
                        }
                        return Decimal128(floatLiteral: temp) / (realmController.account.balance + Decimal128(floatLiteral: -temp))
                    }(), isPercent: true)
                    AccountItemView(name: "Average RR", value: {
                        var rrList: [Double] = []
                        for i in realmController.account.trades.filter("dateEntered BETWEEN {%@, %@} AND win = true AND isHindsight = false AND isDeleted = false", date.startOfMonth(), date.endOfMonth()) {
                            if i.riskToReward > 0 {
                                rrList.append(i.riskToReward)
                            }
                        }
                        let num = ((vDSP.mean(rrList) * 100).rounded() / 100).isNaN ? 0.0 : (vDSP.mean(rrList) * 100).rounded() / 100
                        return Decimal128(floatLiteral: num)
                    }(), isInt: true)
                    AccountItemView(name: "# of Trades", value: Decimal128(value: realmController.account.trades.filter("dateEntered BETWEEN {%@, %@} AND isHindsight = false AND isDeleted = false",  date.startOfMonth(), date.endOfMonth()).count), isInt: true)
                }
                
                // MARK: - YTD Stats
                
                Section(header: Text("YTD Stats")){
                    AccountItemView(name: "P/L", value: {
                        var temp: Decimal128 = 0.0
                        for i in realmController.account.trades.filter("dateEntered BETWEEN {%@, %@} AND isHindsight = false AND isDeleted = false",  date.startOfYear(), date) {
                                temp += i.p_l
                                temp -= i.fees
                        }
                        return temp
                    }())
                    AccountItemView(name: "P/L%", value: {
                        var temp: Double = 0.0
                        for i in realmController.account.trades.filter("dateEntered BETWEEN {%@, %@} AND isHindsight = false AND isDeleted = false", date.startOfYear(), date)  {
                            temp += Double(i.p_l.stringValue) ?? 0.0
                            temp -= Double(i.fees.stringValue) ?? 0.0
                        }
                        return Decimal128(floatLiteral: temp) / (realmController.account.balance + Decimal128(floatLiteral: -temp))
                    }(), isPercent: true)
                    AccountItemView(name: "Average RR", value: {
                        var rrList: [Double] = []
                        for i in realmController.account.trades.filter("dateEntered BETWEEN {%@, %@} AND win = true AND isHindsight = false AND isDeleted = false", date.startOfYear(), date) {
                            if i.riskToReward > 0 {
                                rrList.append(i.riskToReward)
                            }
                            
                        }
                        let num = ((vDSP.mean(rrList) * 100).rounded() / 100).isNaN ? 0.0 : (vDSP.mean(rrList) * 100).rounded() / 100
                        return Decimal128(floatLiteral: num)
                    }(), isInt: true)
                    AccountItemView(name: "# of Trades", value: Decimal128(value: realmController.account.trades.filter("dateEntered BETWEEN {%@, %@} AND isHindsight = false AND isDeleted = false",  date.startOfYear(), date).count), isInt: true)
                }
            }
            
        }
//        .sheet(isPresented: $newAccountSheet){
//            NewAccountSheet()
//                .environmentObject(realmController)
//        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Account Summary")
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing){
//                Menu{
//                    ForEach(realmController.accounts){ a in
//                        Button {
//                            realmController.switchAccount(name: a.name)
//                        } label: {
//                            if realmController.account.name == a.name{
//                                Label(a.name, systemImage: "checkmark")
//                            }else{
//                                Text(a.name)
//                            }
//                        }
//                    }
//                    
//                    // Add New Account Button
//                    Button {
//                        newAccountSheet.toggle()
//                    } label: {
//                        Text("+ New Account")
//                    }
//
//                }label: {
//                    Image(systemName: "line.3.horizontal.circle")
//                        .resizable()
//    //                        .scaledToFit()
//                        .frame(width: 20, height: 20)
//                        .foregroundColor(.green)
//                }
//                
//            }
//        }
        .onAppear{
            menuController.showListView = true
        }
        .onDisappear{
            menuController.showListView = false
        }
    }
}

// MARK: - AccountItemView
struct AccountItemView: View{
    var myFormatter = MyFormatter()
    
    var name: String
    var value: Decimal128
    var isInt: Bool = false
    var isPercent: Bool = false
    var allowTap: Bool = true
    
    @State var showEditAccount: Bool = false
    
    var body: some View{
        HStack(alignment: .center){
            Text(name)
                .bold()
            Spacer()
            if !isInt && !isPercent{
                Text(myFormatter.numFormat(num: value))
            }else if isInt{
                Text(myFormatter.formatAccountInts(num: value))
            }else if isPercent{
                Text(myFormatter.percentFormat(num: Double(value.stringValue) ?? 0.0))
            }
        }
//        .onTapGesture(perform: {
//            showEditAccount.toggle()
//        })
        .sheet(isPresented: $showEditAccount){
            EditAccount()
                .presentationDetents([.height(UIScreen.main.bounds.height / 2)])
        }
        .frame(height: 20)
        .onAppear(perform: {
            
        })

    }
}

// MARK: - New Account Sheet
struct NewAccountSheet: View{
    @EnvironmentObject var realmController: RealmController
    @Environment(\.presentationMode) var presentationMode
    @State var name: String = ""
    @State var balance: String = ""
    
    var body: some View{
        NavigationView {
            Form{
                Section(header: Text("Name")){
                    TextField("", text: $name)
                }
                
                Section(header: Text("Balance")){
                    TextField("", text: $balance)
                }
            }
            .navigationTitle("New Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button{
                        realmController.newAccount(name: name, balance: balance)
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Done")
                    }
                }
            }
        }
    }
}

// MARK: - EditAccount
struct EditAccount: View {
    var body: some View{
        Text("Hello world!")
    }
}

// MARK: - Account Pager
struct AccountPager: View{
    @EnvironmentObject var realmController: RealmController
    @EnvironmentObject var menuController: MenuController
    var myFormatter = MyFormatter()
    @State var pageSelection: Int = 1
    @State private var newAccountSheet: Bool = false
    var body: some View{
        NavigationStack{
            PagerTabStripView(selection: $pageSelection) {
                AccountView()
                    .environmentObject(realmController)
                    .environmentObject(menuController)
                    .pagerTabItem(tag: 1) {
                       Text("All")
                            .opacity(pageSelection != 1 ? 0.5 : 1.0)
                    }
                if UserDefaults.standard.bool(forKey: "personalDevice"){
                    ScrollableMonthView()
                        .environmentObject(realmController)
                    //                    .environmentObject(menuController)
                        .pagerTabItem(tag: 2) {
                            Text("Calendar")
                                .opacity(pageSelection != 2 ? 0.5 : 1.0)
                        }
                }
            }
            .pagerTabStripViewStyle(.barButton(placedInToolbar: false, pagerAnimationOnSwipe: .default, tabItemSpacing: 15, tabItemHeight: 30, indicatorView: { Rectangle().fill(.green).cornerRadius(5)}))
            .sheet(isPresented: $newAccountSheet){
                NewAccountSheet()
                    .environmentObject(realmController)
            }
            .navigationTitle("Account Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing){
                    Menu{
                        ForEach(realmController.accounts){ a in
                            Button {
                                realmController.switchAccount(name: a.name)
                            } label: {
                                if realmController.account.name == a.name{
                                    Label(a.name, systemImage: "checkmark")
                                }else{
                                    Text(a.name)
                                }
                            }
                        }
                        
                        // Add New Account Button
                        Button {
                            newAccountSheet.toggle()
                        } label: {
                            Text("+ New Account")
                        }

                    }label: {
                        Image(systemName: "line.3.horizontal.circle")
                            .resizable()
        //                        .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.green)
                    }
                    
                }
            }

        }
        .tint(.green)
    }
}

// MARK: - Calendar View



//struct CalendarView_Previews: PreviewProvider {
//    static var previews: some View {
//        MonthView()
//    }
//}


//struct ExampleCalendarView: View {
//    @ObservedObject private var calendarManager: MonthlyCalendarManager
//    @EnvironmentObject var realmController: RealmController
//    var tradesbyday: [Date: [Trade]] = [:]
//    // Start & End date should be configured based on your needs.
//    let startDate = Date().addingTimeInterval(TimeInterval(60 * 60 * 24 * (-30 * 36)))
//    let endDate = Date().addingTimeInterval(TimeInterval(60 * 60 * 24 * (30 * 36)))
//    init(trades: [Trade], initialMonth: Date?) {
//        let configuration = CalendarConfiguration(calendar: Calendar.current,
//                                                      startDate: Date(),
//                                                      endDate:  Date().addingTimeInterval(TimeInterval(60 * 60 * 24 * (30 * 36))))
//        calendarManager = MonthlyCalendarManager(configuration: configuration,
//                                                 initialMonth: initialMonth)
//        
//        tradesbyday = createTrades(trades: trades)
//    
//        calendarManager.datasource = self
//        calendarManager.delegate = self
//        }
//
//    var body: some View {
//        ZStack {
//                    MonthlyCalendarView(calendarManager: calendarManager)
//                }
//    }
//    
//    func createTrades(trades: [Trade]) -> [Date: [Trade]]{
//        var temp: [Date: [Trade]] = [:]
//        return temp
//    }
//
//}
//
//extension ExampleCalendarView: MonthlyCalendarDataSource {
//
//    func calendar(backgroundColorOpacityForDate date: Date) -> Double {
//        let startOfDay = Calendar.current.startOfDay(for: date)
//        return 0
//    }
//
//    func calendar(canSelectDate date: Date) -> Bool {
//        let day = Calendar.current.dateComponents([.day], from: date).day!
//        return day != 4
//    }
//
////    func calendar(viewForSelectedDate date: Date, dimensions size: CGSize) -> AnyView {
////        return
////    }
//
//}
//
//extension ExampleCalendarView: MonthlyCalendarDelegate {
//
//    func calendar(didSelectDay date: Date) {
//        print("Selected date: \(date)")
//    }
//
//    func calendar(willDisplayMonth date: Date) {
//        print("Will show month: \(date)")
//    }
//
//}

//struct ExampleMonthlyCalendarView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExampleCalendarView(initialMonth: nil)
//    }
//}

//struct CalendarView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExampleCalendarView()
//    }
//}






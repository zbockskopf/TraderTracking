//
//  MonthView.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 1/7/24.
//

import SwiftUI
import RealmSwift

struct MonthView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var realmController: RealmController
    var myformatter = MyFormatter()
    @State var currentMonthDate: Date
    let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    let currentCalendar = Calendar.current
    @State var trades: Results<Trade>
    @State var reachedEndOfLookback: Bool = false
    @State private var selectedDate: Date?
    @State private var showSelectedDate: Bool = false
    @Binding var showCalendarView: Bool
    
    var showCurrentMonthOnly: Bool = false
    private var oldestTradeDate: Date {
        realmController.account.trades.sorted(byKeyPath: "dateEntered", ascending: true).first?.dateEntered ?? Date()
    }
    
    var stats = ["P&L", "# Trades", "%", "Avg RR"]

    var body: some View {
        VStack{
            HStack {
                // Button to go back to the previous month
                if !showCurrentMonthOnly{
                    Button(action: {
                        goToPreviousMonth()
                       
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(.green)
                    }
                    .disabled(reachedEndOfLookback)
                }
                

                Spacer()

                // Month name header
                Text(monthName(from: currentMonthDate))
                    .font(.title)
                    .fontWeight(.bold)
                    .onTapGesture {
                        showCalendarView.toggle()
                    }

                Spacer()
                
                if !showCurrentMonthOnly{
                    // Button to go forward to the next month (only enabled if not current month)
                    Button(action: goToNextMonth) {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.green)
                    }
                    .disabled(isCurrentMonth)
                }
               
            }
            .padding()

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
                // Weekdays header
                ForEach(weekdays, id: \.self) { weekday in
                    Text(weekday)
                        .fontWeight(.bold)
                }
                
                // Empty cells for offset
                ForEach(0..<getStartDayOffset(), id: \.self) { _ in
                    Text("")
                }
                
                // Days in month
                ForEach(getDaysInMonth(), id: \.self) { day in
                    var pnl = getDayPnL(day: day)
                    Circle()
                        .stroke(Calendar.current.startOfDay(for: Date()) == day ? (colorScheme == .light ? Color.black : .white) : Color.clear)
                        .fill(day == selectedDate ? .blue : pnl == 0 ? .clear : pnl > 0 ? .green : .red)
                        .opacity(0.5)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text(day, format: .dateTime.day())
                                .opacity(!day.isWeekend ? day > Date() ? 0.5 : 1.0 : 0.5)
                        )
                        .onTapGesture {
                            if day < Date() && !day.isWeekend{
                                if day == selectedDate && showSelectedDate == true{
                                    showSelectedDate = false
                                    selectedDate = nil
                                }else{
                                    selectedDate = day
                                    showSelectedDate = true
                                }
                            }
                        }
                        .onChange(of: selectedDate) { oldValue, newValue in
//                            print(oldValue, newValue)
                        }
                }

            }
            
            if showSelectedDate{
                Divider()
                VStack(alignment: .leading){
                    Text(myformatter.statsDailyDate(date: selectedDate!))
                        .font(.title2)
                        .padding(.leading, 20)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(),spacing: 0, alignment: .center), count: 4), spacing: 5){
                        ForEach(stats, id: \.self) { stat in
                            Text(stat)
                                .fontWeight(.bold)
                        }
                    }
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(),spacing: 0, alignment: .center), count: 4), spacing: 5){
                        let dayTrades = realmController.account.trades.filter("dateEntered BETWEEN {%@, %@}", Calendar.current.startOfDay(for: selectedDate!), selectedDate!.endOfDay())
                        ForEach(0...3, id: \.self) { i in
                            switch i {
                            case 0:
                                let p_l: Decimal128 = dayTrades.sum(ofProperty: "p_l")
                                let fees: Decimal128 = dayTrades.sum(ofProperty: "fees")
                                Text(myformatter.numFormat(num: p_l - fees))
                            case 1:
                                Text(String(dayTrades.count))
                            case 2:
                                let p_l: Decimal128 = dayTrades.sum(ofProperty: "p_l")
                                let accountBalanceBefore = realmController.account.balance - p_l
                                Text(String(myformatter.percentFormat(num: Double(p_l.doubleValue / accountBalanceBefore.doubleValue))))
                            case 3:
                                let sumRR: Double = dayTrades.filter("riskToReward > 0").sum(ofProperty: "riskToReward")
                                let RR: Double = Double( sumRR / Double(dayTrades.filter("riskToReward > 0").count))
                                Text(String(format: "%.2f",RR))
                            default:
                                Text("")
                            }
                        }
                    }
                    Divider()
                    Spacer()

                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
//            else{
//                VStack(alignment: .leading){
//                    Text("Monthly")
//                        .font(.title2)
//                        .padding(.leading, 20)
//                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(),spacing: 0, alignment: .center), count: 4), spacing: 5){
//                        ForEach(stats, id: \.self) { stat in
//                            Text(stat)
//                                .fontWeight(.bold)
//                        }
//                    }
//                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(),spacing: 0, alignment: .center), count: 4), spacing: 5){
//                        let monthlyTrades = realmController.account.trades.filter("dateEntered BETWEEN {%@, %@}", currentMonthDate.startOfMonth(), currentMonthDate.endOfMonth())
//                        ForEach(0...3, id: \.self) { i in
//                            switch i {
//                            case 0:
//                                let p_l: Decimal128 = monthlyTrades.sum(ofProperty: "p_l")
//                                let fees: Decimal128 = monthlyTrades.sum(ofProperty: "fees")
//                                Text(myformatter.numFormat(num: p_l - fees))
//                            case 1:
//                                Text(String(monthlyTrades.count))
//                            case 2:
//                                let p_l: Decimal128 = monthlyTrades.sum(ofProperty: "p_l")
//                                let accountBalanceBefore = realmController.account.balance - p_l
//                                Text(String(myformatter.percentFormat(num: Double(p_l.doubleValue / accountBalanceBefore.doubleValue))))
//                            case 3:
//                                let sumRR: Double = monthlyTrades.filter("riskToReward > 0").sum(ofProperty: "riskToReward")
//                                let RR: Double = Double( sumRR / Double(monthlyTrades.filter("riskToReward > 0").count))
//                                Text(String(format: "%.2f",RR))
//                            default:
//                                Text("")
//                            }
//                        }
//                    }
//                    Divider()
//                    Text("Weekly")
//                        .font(.title2)
//                        .padding(.leading, 20)
//                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(),spacing: 0, alignment: .center), count: 4), spacing: 5){
//                        ForEach(stats, id: \.self) { stat in
//                            Text(stat)
//                                .fontWeight(.bold)
//                        }
//                    }
//                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(),spacing: 0, alignment: .center), count: 4), spacing: 5){
//                        let weeklyTrades = realmController.account.trades.filter("dateEntered BETWEEN {%@, %@}", currentMonthDate.startOfTheWeek, currentMonthDate.endOfWeek())
//                        
//                        ForEach(0...3, id: \.self) { i in
//                            switch i {
//                            case 0:
//                                let p_l: Decimal128 = weeklyTrades.sum(ofProperty: "p_l")
//                                let fees: Decimal128 = weeklyTrades.sum(ofProperty: "fees")
//                                Text(myformatter.numFormat(num: p_l - fees))
//                            case 1:
//                                Text(String(weeklyTrades.count))
//                            case 2:
//                                let p_l: Decimal128 = weeklyTrades.sum(ofProperty: "p_l")
//                                let accountBalanceBefore = realmController.account.balance - p_l
//                                Text(String(myformatter.percentFormat(num: Double(p_l.doubleValue / accountBalanceBefore.doubleValue))))
//                            case 3:
//                                let sumRR: Double = weeklyTrades.filter("riskToReward > 0").sum(ofProperty: "riskToReward")
//                                let RR: Double = Double( sumRR / Double(weeklyTrades.filter("riskToReward > 0").count))
//                                Text(String(format: "%.2f",RR))
//                            default:
//                                Text("")
//                            }
//                        }
//                    }
//                    Divider()
//                    Spacer()
//
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//            }
            
        }
        

    }
    
    // Helper functions and properties
    var isCurrentMonth: Bool {
        currentCalendar.isDateInToday(currentMonthDate)
    }
    
    func monthName(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM YYYY"
        return formatter.string(from: date)
    }
    
    func statsMonthName(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date)
    }

    func goToPreviousMonth() {
        if let newDate = currentCalendar.date(byAdding: .month, value: -1, to: currentMonthDate) {
            currentMonthDate = newDate
            trades = realmController.account.trades.filter("dateEntered BETWEEN {%@, %@} AND isDeleted = false", currentMonthDate.startOfMonth(), currentMonthDate.endOfMonth())
            if realmController.account.trades.filter("dateEntered BETWEEN {%@, %@} AND isDeleted = false", currentCalendar.date(byAdding: .month, value: -2, to: newDate)!.startOfMonth(), currentCalendar.date(byAdding: .month, value: -2, to: newDate)!.endOfMonth()).count == 0{
                reachedEndOfLookback.toggle()
            }
        }
       
    }
    func goToNextMonth() {
        if let newDate = currentCalendar.date(byAdding: .month, value: 1, to: currentMonthDate) {
            currentMonthDate = newDate
            trades = realmController.account.trades.filter("dateEntered BETWEEN {%@, %@} AND isDeleted = false", currentMonthDate.startOfMonth(), currentMonthDate.endOfMonth())
        }
        reachedEndOfLookback.toggle()
    }

    func getDayPnL(day: Date) -> Double {
//        print(trades)
        var pnl: Decimal128 = realmController.account.trades.filter("dateEntered BETWEEN {%@, %@} AND isDeleted = false", day, Calendar.current.date(byAdding: .day, value: 1, to: day)).sum(ofProperty: "p_l")
        return pnl.doubleValue

    }

    func getStartDayOffset() -> Int {
        let calendar = Calendar.current
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonthDate))!
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        return (weekday + 6) % 7 // Adjusting offset to start from Sunday
    }
    
    func getEndDayOffset() -> Int {
        let calendar = Calendar.current
        let lastDayOfMonth = Date().endOfMonth()
        let weekday = calendar.component(.weekday, from: lastDayOfMonth)
        return (weekday + 6) % 7 // Adjusting offset to start from Sunday
    }

    func getDaysInMonth() -> [Date] {
        var days: [Date] = []
        
        // Get the current calendar
        let calendar = Calendar.current
        
        // Get the current date
        let currentDate = Date()
        
        // Get the range of days in the current month
        guard let range = calendar.range(of: .day, in: .month, for: currentMonthDate) else { return [] }
        
        // Get the first day of the month
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonthDate))!
        
        // Iterate over the range and add each day to the array
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        return days
    }

}



//struct ScrollableMonthView: View {
//    @State private var baseDate: Date = Date() // This date decides which months to show
//    @EnvironmentObject var realmController: RealmController
//
//    // Calculate the dates for the previous, current, and next months
//     func monthOffset(_ offset: Int) -> Date {
//         let oldestTrade = Calendar.current.dateComponents([.month], from: realmController.account.trades.sorted(byKeyPath: "dateEntered", ascending: true).first!.dateEntered, to: Date()).month
//         print(oldestTrade, realmController.account.trades.sorted(byKeyPath: "dateEntered", ascending: true).first!.dateEntered)
//        guard let offsetDate = Calendar.current.date(byAdding: .month, value: -offset, to: baseDate) else {
//            return baseDate
//        }
//        return offsetDate
//    }
//    
//    var body: some View {
//        ScrollViewReader { scrollView in
//            List {
//                let oldestTrade = Calendar.current.dateComponents([.month], from: realmController.account.trades.sorted(byKeyPath: "dateEntered", ascending: true).first!.dateEntered, to: Date()).month
//                ForEach(-1..<(oldestTrade ?? 1) + 1) { offset in // Example range: 1 year before and after the base date
//                    MonthView(
//                        currentMonthDate: monthOffset(offset),
//                        trades: realmController.account.trades.filter("dateEntered BETWEEN {%@, %@}", monthOffset(offset).startOfMonth(), monthOffset(offset).endOfMonth()),
//                        showCurrentMonthOnly: true
//                    )
//                    .id(offset)
//                    .padding(.vertical)
//                }
//            }
//            .onAppear {
////                scrollView.scrollTo(0,anchor: .top)
//            }
//        }
//    }
//}

//#Preview {
//    MonthView()
//}

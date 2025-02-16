//
//  ScrollableMonthView.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 2/15/25.
//

import SwiftUI


struct ScrollableMonthView: View {
    var onDismiss: (() -> Void)?
    @State private var baseDate: Date = Date()
    @EnvironmentObject var realmController: RealmController
    @EnvironmentObject var menuController: MenuController

    // This property should be calculated once and reused
    private var oldestTradeDate: Date {
        realmController.account.trades.sorted(byKeyPath: "dateEntered", ascending: true).first?.dateEntered ?? Date()
    }
    
    private var monthRange: Int {
        Calendar.current.dateComponents([.month], from: oldestTradeDate, to: baseDate).month ?? 0
    }

    private func monthOffset(_ offset: Int) -> Date {
        print(offset)
        return Calendar.current.date(byAdding: .month, value: -offset, to: baseDate) ?? baseDate
    }

    var body: some View {
        ScrollViewReader { scrollView in
//            ScrollView{
                List {
                    ForEach(-1...monthRange, id: \.self) { offset in
                        let currentMonthDate = monthOffset(-offset)
                        let startOfMonth = currentMonthDate.startOfMonth()
                        let endOfMonth = currentMonthDate.endOfMonth()

                        MonthView(
                            currentMonthDate: currentMonthDate,
                            trades: realmController.account.trades.filter("dateEntered BETWEEN {%@, %@} AND isDeleted = false", startOfMonth, endOfMonth),
                            showCalendarView:.constant(false), showCurrentMonthOnly: true
                        )
                        .id(offset)
                        .padding(.vertical)
                    }
//                    .listRowSeparator(.hidden)
                }
                .navigationBarBackButtonHidden(true)
                .navigationTitle("Calendar")
                .onAppear {
                    menuController.showListView = true
                    // Consider scrolling to a specific month here
//                    withAnimation {
                        scrollView.scrollTo(0, anchor: .center)

//                    }
                }
                .onDisappear {
                    onDismiss?()
                }
//            }

        }
    }
}

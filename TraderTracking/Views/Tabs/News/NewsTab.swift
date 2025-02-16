//
//  NewsTab.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 2/3/23.
//

import SwiftUI
import PagerTabStripView

struct NewsTab: View {
    @EnvironmentObject var newsController: ForexCrawler
    @EnvironmentObject var menuController: MenuController
    var myFormatter = MyFormatter()
    @State var currentTime: String = ""
    @State var test: Color = .blue
    var newsWeekDates: [Date]
    @State var newsWeekDatesShoudlTrade: [(Date,Color)] = []
    var news: [News]
    var x: Int = 22

    var filteredNews: [[News]] {
        newsWeekDates.map { date in
            let start = startOfDay(date: date)
            let end = endOfDay(date: date)
            return news.filter { $0.date > start && $0.date < end && impactFilters.contains($0.impact) && currencyFilters.contains($0.currecny) }.sorted { $0.date < $1.date }
        }
    }

    var impactFilters: [NewsImpact] {
        var temp: [NewsImpact] = []
        if newsController.showHighImpact { temp.append(.high) }
        if newsController.showMediumImpact { temp.append(.medium) }
        if newsController.showLowImpact { temp.append(.low) }
        return temp
    }

    var currencyFilters: [String] {
        newsController.newsCurrenciesFilter.compactMap { $0.value ? $0.key : nil }
    }

    var body: some View {
        if newsController.dailyNews.isEmpty {
            Text("No News Today")
        } else {
            ScrollViewReader { scrollView in
                List {
                    ForEach(Array(zip(newsWeekDates, filteredNews)), id: \.0) { date, news in
                        Section(header: newsSectionHeader(date: date)) {
                            ForEach(news, id: \.self) { news in
                                if (news.time != "All Day" && news.time != "Tentative") {
                                    NewRow(news: news, currentTime: $currentTime)
                                        .opacity(news.date < Date() ? 0.3 : 1.0)
                                }
                            }
                        }
                        .id(date)
                    }
                }
                .onAppear {
                    if menuController.newsDoesScrollToToday {
                        scrollView.scrollTo(getScrollID(), anchor: .top)
                    }
                }
                .safeAreaPadding([.top],23)
            }
        }
    }

    func getScrollID() -> Date {
        return newsWeekDates.first(where: { Calendar.current.isDateInToday($0) }) ?? newsWeekDates.first ?? Date()
    }

    func startOfDay(date: Date) -> Date {
        return Calendar.current.startOfDay(for: date)
    }

    func endOfDay(date: Date) -> Date {
        return Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: date) ?? date
    }

    @ViewBuilder
    func newsSectionHeader(date: Date) -> some View{
        HStack{
            myFormatter.headerDate(date: date)
            Spacer()
            Button(action: {
                if let index = newsWeekDatesShoudlTrade.firstIndex(where: { $0.0 == date }) {
                    switch newsWeekDatesShoudlTrade[index].1 {
                    case .gray:
                        newsWeekDatesShoudlTrade[index].1 = .green
                    case .green:
                        newsWeekDatesShoudlTrade[index].1 = .red
                    case .red:
                        newsWeekDatesShoudlTrade[index].1 = .gray
                    default:
                        newsWeekDatesShoudlTrade[index].1 = .blue
                    }
                    
                }
            }, label: {
            })
        }
        
    }
}






//struct NewsTab: View {
//    @EnvironmentObject var newsController: ForexCrawler
//    @EnvironmentObject var menuController: MenuController
//    var myFormatter = MyFormatter()
//    @State var currentTime: String = ""
//    @State var test: Color = .blue
//    var newsWeekDates: [Date]
//    @State var newsWeekDatesShoudlTrade: [(Date,Color)] = []
//    var news: [News]
//    var x: Int = 22
//    var body: some View {
////        NavigationStack{
//            if newsController.dailyNews.count == 0 {
//                Text("No News Today")
//            }else{
//                ScrollViewReader{ scrollView in
//                    List{
//                        ForEach(0...newsWeekDates.count - 1, id: \.self) { i in
////                            myFormatter.headerDate(date: newsWeekDates[i]))
//                            Section(header: newsSectionHeader(date: newsWeekDates[i])){
//                                ForEach(news.filter{$0.date > startOfDay(date: newsWeekDates[i]) && $0.date < endOfDay(date: newsWeekDates[i]) && filterArray().contains($0.impact) && filterCurrencies().contains($0.currecny)}.sorted{$0.date < $1.date}, id: \.self) { news in
//
//                                    if (news.time != "All Day" && news.time != "Tentative"){
//                                        NewRow(news: news, currentTime: $currentTime)
//                                            .opacity(news.date < Date() ? 0.3 : 1.0)
//                                    }
//                                }
//                            }
//                            .id(newsWeekDates[i])
//                        }
//                    }
//                    .onAppear{
//                        if menuController.newsDoesScrollToToday{
////                            withAnimation {
//                                scrollView.scrollTo(getScrollID(), anchor: .top)
////                            }
//                        }
//                    }
//                }
//                .safeAreaPadding([.top],23)
//            }
////        }
//    }
//    
//    func filterArray() -> [NewsImpact]{
//        var temp: [NewsImpact] = []
//        if newsController.showHighImpact{
//            temp.append(.high)
//        }
//        if newsController.showMediumImpact{
//            temp.append(.medium)
//        }
//        if newsController.showLowImpact{
//            temp.append(.low)
//        }
//
//        return temp
//    }
//    
//    func filterCurrencies() -> [String]{
//        var temp: [String] = []
//        for i in newsController.newsCurrenciesFilter{
//            if i.value{
//                temp.append(i.key)
//            }
//        }
//        return temp
//    }
//    
//    func getScrollID() -> Int{
//        return newsWeekDates.firstIndex(of: Calendar.current.startOfDay(for: Date())) ?? 0
//    }
//
//    func startOfDay(date: Date) -> Date {
//        let startOfDay = Calendar.current.startOfDay(for: date)
//        return startOfDay
//    }
//
//    func endOfDay(date: Date) -> Date {
//        let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: date)
//        return endOfDay!
//    }
//    @ViewBuilder
//    func newsSectionHeader(date: Date) -> some View{
//        HStack{
//            myFormatter.headerDate(date: date)
//            Spacer()
//            Button(action: {
//                if let index = newsWeekDatesShoudlTrade.firstIndex(where: { $0.0 == date }) {
//                    switch newsWeekDatesShoudlTrade[index].1 {
//                    case .gray:
//                        newsWeekDatesShoudlTrade[index].1 = .green
//                    case .green:
//                        newsWeekDatesShoudlTrade[index].1 = .red
//                    case .red:
//                        newsWeekDatesShoudlTrade[index].1 = .gray
//                    default:
//                        newsWeekDatesShoudlTrade[index].1 = .blue
//                    }
//                    
//                }
//            }, label: {
////                Circle()
////                    .foregroundStyle(newsWeekDatesShoudlTrade.first(where: { $0.0 == date })!.1)
////                    .frame(width: 10,height: 10)
//            })
//        }
//        
//    }
//}
//
struct NewRow: View {
    var news: News
    @Binding var currentTime: String
    var body: some View {
        HStack{
//            Text(news.isSameTime ? "" : (news.time == "All Day" ? "All Day" : news.time))
            Text(news.time)
                .frame(width: 60)
                .font(.system(size: 14))
                .padding([.trailing], 2)
            Text(news.currecny)
                .frame(width: 30)
                .font(.system(size: 14))
                .padding([.trailing], 2)
            Image(systemName: "newspaper.circle.fill")
                .foregroundColor(getColor())
                .fixedSize()
            Text(news.name)
                .font(.system(size: 14))
        }
    }

    func getColor() -> Color{
        switch news.impact{
        case .high:
            return .red
        case .medium:
            return .orange
        case .low:
            return .yellow
        case .none:
            return Color(uiColor: .label)
        }
    }
}

struct NewsPager: View{
    @EnvironmentObject var newsController: ForexCrawler
    @EnvironmentObject var menuController: MenuController
    var myFormatter = MyFormatter()
    @State var pageSelection: Int = 1
    var body: some View{
        NavigationStack{
//            PagerTabStripView(selection: $pageSelection) {
                var newsDates = Date().newsWeekDates + Date().newsNextWeekDates
                var news = newsController.dailyNews + newsController.nextWeekNews
                NewsTab(newsWeekDates: newsDates, newsWeekDatesShoudlTrade: createNewsWeekShouldTrade(currentWeek: true), news: news)
                    .environmentObject(newsController)
                    .environmentObject(menuController)
//                    .pagerTabItem(tag: 1) {
//                       Text("Current Week")
//                            .opacity(pageSelection != 1 ? 0.5 : 1.0)
//                    }
//                NewsTab(newsWeekDates: Date().newsNextWeekDates, newsWeekDatesShoudlTrade: createNewsWeekShouldTrade(nextWeek: true), news: newsController.nextWeekNews)
//                    .environmentObject(newsController)
//                    .environmentObject(menuController)
//                    .pagerTabItem(tag: 2) {
//                        Text("Next Week")
//                            .opacity(pageSelection != 2 ? 0.5 : 1.0)
//                    }
//            }
//            .pagerTabStripViewStyle(.barButton(placedInToolbar: false, pagerAnimationOnSwipe: .default, tabItemSpacing: 15, tabItemHeight: 30, indicatorView: { Rectangle().fill(.green).cornerRadius(5)}))
            .navigationTitle("USD News")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing) {
//                    if #available(iOS 16.4, *) {
                        NewsFilterButton()
                        .menuActionDismissBehavior(.disabled)
//                    } else {
//                        NewsFilterButton()
//                            .menuActionDismissBehavior(.disabled)
//                    }

                }
            }

        }
        .tint(.green)
    }
    
    func createNewsWeekShouldTrade(currentWeek: Bool = false, nextWeek: Bool = false) -> [(Date,Color)]{
        var news = currentWeek ? Date().newsWeekDates : nextWeek ? Date().newsNextWeekDates : []
        var newsShouldTrade: [(Date,Color)] = []
        for i in news{
            newsShouldTrade.append((i,.gray))
        }
        return newsShouldTrade
    }
}

//struct PagerTabStripView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewsPager()
//    }
//}

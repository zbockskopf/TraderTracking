//
//  TradesListView.swift
//  TraderTracking
//
//  Created by Zach on 9/15/22.
//

import SwiftUI
import RealmSwift
import ImageUI


struct TradesListView: View {

    @EnvironmentObject var realmController: RealmController
    @EnvironmentObject var tradeListData: TradeListViewModel
    @EnvironmentObject var menuController: MenuController
    @EnvironmentObject var newsController: ForexCrawler
    
    @ObservedRealmObject var account: Account

//    @State var trades: [Trade] = []
//    @State var account: [Account] = []
    @State var imageIsShown: Bool = false
    @State var tappedImageShown: Bool = false
    @State var showDot: Bool = false

    @State private var all: Bool?
    @State private var selectedTrade: Trade? = nil
    @State private var editTrade: Trade? = nil
    @State private var editSheet: Bool = false
    @StateObject var progressBar: DynamicProgress = .init()
    @State var sampleProgress: CGFloat = 0
    
    var calendar = Calendar.current
    var tradesPL: Decimal128 = 0.0
    var myFormatter = MyFormatter()
    var myImages = MyImages()


    var body: some View {
        ZStack{
        NavigationStack{
            List {
                if menuController.showAllTrades{
                    ForEach(account.trades.filter(getFilter()).sorted(by: {$0.dateEntered > $1.dateEntered})){ t in
                        TradeRow(trade: t, selectedTrade: $selectedTrade, imageIsShown: $imageIsShown, showDot: $showDot, isAll: menuController.showAllTrades)
                            .contextMenu{
                                Button(action: {
                                    realmController.tradeReviewed(trade: t)
                                }, label: {
                                    Label(t.reviewed ? "Unreview" : "Reviewed", systemImage: "checkmark.square.fill")
                                })
                            }
//                            .onTapGesture {
//                                selectedTrade = t
//                                //                                    if t.photoDirectory != nil {
//
//                                //                                    }
//                            }
                            .swipeActions(edge: .leading, content: {
                                Button {
                                    editTrade = t
                                } label: {
                                    Label("", systemImage: "pencil")
                                }
                                .tint(.green)
                            })
                            .swipeActions(edge: .trailing) {
                                Button{
                                    sampleProgress = 0
                                    realmController.updateAccountAfterTradeDelete(trade: t)
                                    progressBar.deletedTrades.append(t)
//                                    withAnimation{
                                        realmController.toggleTradeIsDeleted(trade: t)
//                                    }
                                    realmController.getWinRate()
                                    if !progressBar.isAdded{
                                        progressBar.undo = false
                                        progressBar.isAdded.toggle()
                                    }
                                } label: {
                                    Text("Delete")
                                        .foregroundColor(.white)
                                }
                                .tint(.red)
                            }
                    }
                } else {
                    ForEach(Date().tradeListWeekDates.reversed(), id: \.self){ date in
//                        myFormatter.headerDate(date: date)
                        Section(header: myFormatter.headerDate(date: date)){
                            ForEach(account.trades.filter("dateEntered BETWEEN {%@, %@} AND " + getFilter(), startOfDay(date: date), endOfDay(date: date)).sorted(byKeyPath: "dateEntered", ascending: true).list.reversed()){ t in
                                TradeRow(trade: t, selectedTrade: $selectedTrade, imageIsShown: $imageIsShown, showDot: $showDot, isAll: menuController.showAllTrades)
                                    .contextMenu{
                                        Button(action: {
                                            realmController.tradeReviewed(trade: t)
                                        }, label: {
                                            Label(t.reviewed ? "Unreview" : "Reviewed", systemImage: "checkmark.square.fill")
                                        })
                                    }
//                                    .onTapGesture {
//                                        Link("Notes", destination: URL(string: t.noteURL!)!)
////                                        selectedTrade = t
//                                        //                                    if t.photoDirectory != nil {
//
//                                        //                                    }
//                                    }
                                    .swipeActions(edge: .leading, content: {
                                        Button {
                                            editTrade = t
                                        } label: {
                                            Label("", systemImage: "pencil")
                                        }
                                        .tint(.green)
                                    })
                                    .swipeActions(edge: .trailing) {
                                        Button{
                                            sampleProgress = 0
                                            realmController.updateAccountAfterTradeDelete(trade: t)
                                            progressBar.deletedTrades.append(t)
//                                            withAnimation{
                                                realmController.toggleTradeIsDeleted(trade: t)
//                                            }
                                            realmController.getWinRate()
                                            if !progressBar.isAdded{
                                                progressBar.undo = false
                                                progressBar.isAdded.toggle()
                                            }
                                        } label: {
                                            Text("Delete")
                                                .foregroundColor(.white)
                                        }
                                        .tint(.red)
                                    }

                            }
                        }
                        .onAppear(perform: {
                            UITableView.appearance().sectionFooterHeight = 0
                        })
                    }
                }
            }
            .sheet(item: $editTrade){ t in
                NewTradeView(sheetAction: Binding.constant(nil), isEditing: true, trade: t, tradeID: t._id, symbol: t.symbol!.name, dateEntered: t.dateEntered, entry: t.entry.stringValue,
                             dateExited: t.dateExited, exit: t.exit.stringValue, positionSize: String(t.positionSize), selectedPositionType: t.positionType, selectedSession: t.session,
                             stopLoss: t.stopLoss?.stringValue ?? "", takeProfit: t.takeProfit?.stringValue ?? "", isHindsight: t.isHindsight, fees: t.fees.stringValue, photoDirectory: t.photoDirectory ?? "",
                             selectedImages: myImages.loadImageFromDiskWith(directory: t.photoDirectory ?? "") ?? [], noteUrl: t.noteURL ?? "", notes: t.notes, reviewed: t.reviewed,
                             isPartials: (t.partials.count != 0 ? true : false))
                .environmentObject(realmController)
                .environmentObject(newsController)
            }
            .navigationDestination(isPresented: $menuController.showTradeView, destination: {
                TradeView(trade: selectedTrade, images: myImages.loadImageFromDiskWith(directory: selectedTrade?.photoDirectory ?? "") ?? [])
                    .environmentObject(tradeListData)
            })
            .navigationBarTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if #available(iOS 16.4, *) {
                        TradeFilterButton()
                        .menuActionDismissBehavior(.disabled)
                    } else {
                        TradeFilterButton()
                            .foregroundStyle(.green)
                    }
                }
                ToolbarItemGroup(placement: .navigationBarLeading){
                    Text(menuController.showActualPL ? (menuController.showWeekTrades ? realmController.getWeekPandL(hindSight: false) : realmController.pAndL) : menuController.showWeekTrades ? realmController.getWeekPandL(hindSight: true) : realmController.getHindSightPL())
//                    Text(menuController.showHindsightPL ? realmController.getWeekHindSightPL() : menuController.showWeekTrades ? realmController.getWeekPandL() : realmController.pAndL)
                        .foregroundColor(showDot ? Color(uiColor: .clear) : .primary)
                        .overlay(content: {
                            if showDot{
                                Circle()
                                    .fill(.primary)
                                    .frame(width: 15, height: 15)
                                    .onTapGesture(perform:{
                                        showDot.toggle()
                                    })
                                    .padding()
                            }
                        })
                        .onTapGesture(perform:{
                            showDot.toggle()
                        })
                }
            }
        }
        .tint(.green)
            if progressBar.isAdded{
                DynamicProgressView(config: ProgressConfig(title: "iJustine Image", progressImage: "arrow.clockwise", expandedImage: "clock.badge.checkmark.fill", tint: .green,rotationEnabled: true))
                        .environmentObject(progressBar)
                        .environmentObject(realmController)
            }
        }
        .onChange(of: selectedTrade){ val in
            if val != nil{
                menuController.showTradeView.toggle()
            }
        }
        .onChange(of: menuController.showTradeView) { val in
            if !val {
                selectedTrade = nil
            }
        }
        .onReceive(Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()) { _ in
            if progressBar.isAdded{
                // Converting to 100 then dividing by 100
                sampleProgress += 0.1
                progressBar.updateProgressView(to: sampleProgress / 100)
            }else{
                sampleProgress = 0
            }
        } 
    }
    
    func getFilter() -> String {
        if menuController.showHindsightTrades {
            return "isHindsight = true"
        }else if menuController.showActualTrades {
            return "isHindsight = false"
        }else{
            return "isDeleted = false"
        }
    }
                                    
    func startOfDay(date: Date) -> Date {
        let startOfDay = calendar.startOfDay(for: date)
        return startOfDay
    }
    
    func endOfDay(date: Date) -> Date {
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)
        return endOfDay!
    }
                                    


    func getImages(all: Bool, trade: Trade?) -> [IFImage] {
        var temp: Results<Trade>

        if all {
            temp = realmController.trades.filter("dateEntered BETWEEN {%@, %@}",Calendar.current.date(byAdding: .day, value: -7, to: Date())!, Date())
        }else{
            temp = realmController.trades.filter("dateEntered BETWEEN {%@, %@}",calendar.startOfDay(for: trade!.dateEntered), calendar.date(bySettingHour: 23, minute: 59, second: 59, of: trade!.dateEntered)!)
        }

        var images: [IFImage] = []
        for i in temp {
            if i.photoDirectory != nil{
                let tempPhotos = realmController.myImage.loadImageFromDiskWith(directory: i.photoDirectory!)!
                for p in tempPhotos {
                    images.append(IFImage(image: p))
                }
            }
        }

        return images
    }

    func getTappedImages(trade: Trade) -> [IFImage] {
        var images: [IFImage] = []

        if trade.photoDirectory != nil{
            let tempPhotos = realmController.myImage.loadImageFromDiskWith(directory: trade.photoDirectory!)!
            for p in tempPhotos {
                images.append(IFImage(image: p))
            }
        }
        images.removeFirst()
        return images
    }
}
// MARK: - Trade Row
struct TradeRow: View {
    @ObservedRealmObject var trade: Trade
    @Binding var selectedTrade: Trade?
    @Binding var imageIsShown: Bool
    @Binding var showDot: Bool
    
    var isAll: Bool

    var myFormatter = MyFormatter()
    let columns = [
        GridItem(.flexible(), spacing: 0, alignment: .leading),
        GridItem(.flexible(), spacing: 0, alignment: .trailing),
        GridItem(.flexible(), spacing: 0, alignment: .trailing)
    ]

    var body: some View {
        VStack(alignment: .leading){
            HStack{
                if isAll {
                    HStack{
                        Text(formatDate(date: trade.dateEntered))
                            .font(.footnote)
                            .opacity(0.5)
                            .padding(.trailing, 10)
                    }
                }else{
                    HStack{
                        Text(trade.dateEntered, style:  .time)
                            .font(.footnote)
                            .opacity(0.5)
                    }
                }
                Spacer()
                if trade.noteURL != nil {
                    Link(destination: URL(string: trade.noteURL!)!){
                        Image(systemName: "note.text").fixedSize()
                    }
                        .allowsHitTesting(true)
                }
                if trade.photoDirectory != nil {
                    Image(systemName: "photo")
                        .fixedSize()
                }
                if trade.reviewed {
                    Image(systemName: "checkmark.square.fill")
                        .foregroundColor(Color.secondary)
                        .opacity(0.5)
                        .frame(width: 15, height: 15)
                }
            }
            .padding([.top], 5)
            LazyVGrid(columns: columns, spacing: 15){
                HStack{
                    Text(trade.symbol!.name)
                        
                        .padding(.trailing, 5)
                    if trade.positionType == .long {
                        Text("long")
                            .frame(alignment: .bottom)
                            .font(.footnote)
                            .opacity(0.7)
                            .foregroundColor(.green)
                    }else{
                        Text("short")
                            .frame(alignment: .bottom)
                            .font(.footnote)
                            .opacity(0.7)
                            .foregroundColor(.red)
                    }
                    if trade.partials.count > 0 {
                        Circle()
                            .fill(.foreground)
                            .frame(width: 5, height: 5)
                            .opacity(0.7)
                    }
                }

                HStack{
                    Image("Entry")
                        .resizable()
                        .scaledToFit()
//                        .font(.footnote)
                        .frame(width: 15, height: 15, alignment: .leading)
                        
                    Text( myFormatter.numFormat(num: trade.entry))
                }

                HStack{
                    Image("Exit")
                        .resizable()
                        .scaledToFit()
//                        .font(.footnote)
                        .frame(width: 15, height: 15, alignment: .leading)
                        
                    Text(myFormatter.numFormat(num: trade.partials.count > 0 ? trade.partials.last!.exit : trade.exit))
                    
                }
            }
            .padding(.bottom, 5)
            LazyVGrid(columns: columns, spacing: 15){
                
                Text(myFormatter.numFormat(num: trade.p_l ))//- trade.fees))
                    .foregroundColor(trade.isHindsight ? .blue : trade.p_l == 0.0 ? .primary : trade.p_l > 0.0 ? .green : .red)
                    .frame(alignment: .leading)
                Text(myFormatter.percentFormat(num: trade.percentGain))
                    .foregroundStyle(trade.percentGain > 0 ? .green : .red)
                Text(trade.riskToReward <= 0.0 ? "" : String(trade.riskToReward) + "rr")
            }
      }
    }
    
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter.string(from: date)
    }
}

struct TradeRow_Preview: PreviewProvider {

    static var previews: some View {
        NavigationView{
            TabView{
                List{
                    Section(header: Text(Date(), style: .date)){
                        test1()
                        test1()
                    }

                    Section(header: Text(Date(), style: .date)){
                        test1()
                        test1()
                    }
                }
            }
        }
    }
}

struct test1: View {

    var body: some View {
        VStack(alignment: .leading){
            HStack{
                if false {
                    Circle()
                        .fill(.blue)
                        .frame(width: 20, height: 20)
                        .padding(.top)
                }else{
                    if true{
                        Circle()
                            .fill(.green)
                            .frame(width: 20, height: 20)
                            .padding(.top)
                    }

                    if false{
                        Circle()
                            .fill(.red)
                            .frame(width: 20, height: 20)
                            .padding(.top)
                    }
                }
                Text("MES")
                    .padding([.top, .leading])
                Spacer()
            }
            Spacer()
            VStack(alignment: .leading){

              HStack{
                Text("Entry:")
                      .bold()
                Text(String(MyFormatter().numFormat(num: 12345.00)) + " @")
                Text(Date(), style: .time)

              }
              .padding([.bottom], 5)

              HStack{
                  Text("Exit:")
                      .bold()
                  Text(String(MyFormatter().numFormat(num: 12345.00)) + " @")
                  Text(Date(), style: .time)
              }
            }
            .padding()

            Spacer()
        HStack{
            HStack{

            }

        }
            Spacer()
      }
    }
}

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


//    @State var trades: [Trade] = []
//    @State var account: [Account] = []
    @State var imageIsShown: Bool = false
    @State var tappedImageShown: Bool = false
    @State var showDot: Bool = true

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
                    ForEach(realmController.allTrades){ t in
                        TradeRow(trade: t, selectedTrade: $selectedTrade, imageIsShown: $imageIsShown, showDot: $showDot, isAll: menuController.showAllTrades)
                            .onTapGesture {
                                selectedTrade = t
                                //                                    if t.photoDirectory != nil {
                                
                                //                                    }
                            }
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
                                    withAnimation{
                                        realmController.toggleTradeIsDeleted(trade: t)
                                    }
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
                }else{
                    ForEach(weekDates().reversed(), id: \.self){ date in
//                        myFormatter.headerDate(date: date)
                        Section(header: myFormatter.headerDate(date: date)){
                            ForEach(realmController.trades.filter("dateEntered BETWEEN {%@, %@}", startOfDay(date: date), endOfDay(date: date))){ t in
                                TradeRow(trade: t, selectedTrade: $selectedTrade, imageIsShown: $imageIsShown, showDot: $showDot, isAll: menuController.showAllTrades)
                                    .onTapGesture {
                                        selectedTrade = t
                                        //                                    if t.photoDirectory != nil {

                                        //                                    }
                                    }
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
                                            withAnimation{
                                                realmController.toggleTradeIsDeleted(trade: t)
                                            }
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
                    }
//                    ForEach(0..<7){ i in
//                        Section(header: myFormatter.headerDate(i: i)) {
//                            ForEach(realmController.trades.filter("dateEntered BETWEEN {%@, %@}", dateChanger(date: Date(), i:i, isPrevDay: false), dateChanger(date: Date(), i:i, isPrevDay: true))){ t in
//                                                            }
//                        }
//                    }
                }
            }
            .sheet(item: $editTrade){ t in
                NewTradeView(sheetAction: Binding.constant(nil), isEditing: true, trade: t, tradeID: t._id,
                             symbol: t.symbol!.name, dateEntered: t.dateEntered, entry: t.entry.stringValue, dateExited: t.dateExited, exit: t.exit.stringValue, positionSize: String(t.positionSize), selectedPositionType: t.positionType, selectedSession: t.session, stopLoss: t.stopLoss?.stringValue ?? "", takeProfit: t.takeProfit?.stringValue ?? "", isHindsight: t.isHindsight, fees: t.fees.stringValue, photoDirectory: t.photoDirectory ?? "", selectedImages: myImages.loadImageFromDiskWith(directory: t.photoDirectory ?? "") ?? [], notes: t.notes ?? ""
                )
                .environmentObject(realmController)
            }
            .navigationDestination(isPresented: $menuController.showTradeView, destination: {
                TradeView(trade: selectedTrade, images: myImages.loadImageFromDiskWith(directory: selectedTrade?.photoDirectory ?? "") ?? [])
                    .environmentObject(tradeListData)
            })
            .navigationBarTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    
                    Menu {
                        Button(action: {
                            menuController.showAllTrades = true
                            menuController.showWeekTrades = false
                        }) {
                            if menuController.showAllTrades{
                                Label("All", systemImage: "checkmark")
                            }else{
                                Text("All")
                            }
                        }
                        
                        Button(action: {
                            menuController.showAllTrades = false
                            menuController.showWeekTrades = true
                        }) {
                            if menuController.showWeekTrades{
                                Label("Week", systemImage: "checkmark")
                            }else{
                                Text("Week")
                            }
                        }
                        Menu{
                            Button(action: {
                                menuController.showHindsightPL = true
                                menuController.showActualPL = false
                            }) {
                                if menuController.showHindsightPL{
                                    Label("Hindsight", systemImage: "checkmark")
                                }else{
                                    Text("Hindsight")
                                }
                            }

                            Button(action: {
                                menuController.showHindsightPL = false
                                menuController.showActualPL = true
                            }) {
                                if menuController.showActualPL{
                                    Label("Actual", systemImage: "checkmark")
                                }else{
                                    Text("Actual")
                                }
                            }
                            
                        } label:{
                            Text("P/L")
                        }
                        
                    }
                label: {
                    Image(systemName: "line.3.horizontal.circle")
                        .resizable()
//                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.green)
                        
                }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing){
                    Text(menuController.showHindsightPL ? realmController.getWeekHindSightPL() : realmController.pAndL)
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
                                    
    func startOfDay(date: Date) -> Date {
        let startOfDay = calendar.startOfDay(for: date)
        return startOfDay
    }
    
    func endOfDay(date: Date) -> Date {
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)
        return endOfDay!
    }
                                    
    func weekDates() -> [Date]{
        let isoDate = "2022-11-04T10:44:00+0000"

        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from:isoDate)!
        
        // Above is for testing
        
        let currentWeekdays = Date().currentWeekdays
        return currentWeekdays
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
                let tempPhotos = RealmController.shared.myImage.loadImageFromDiskWith(directory: i.photoDirectory!)!
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
            let tempPhotos = RealmController.shared.myImage.loadImageFromDiskWith(directory: trade.photoDirectory!)!
            for p in tempPhotos {
                images.append(IFImage(image: p))
            }
        }
        images.removeFirst()
        return images
    }
}

struct TradeRow: View {
    var trade: Trade
    @Binding var selectedTrade: Trade?
    @Binding var imageIsShown: Bool
    @Binding var showDot: Bool
    var isAll: Bool

    var myFormatter = MyFormatter()

    var body: some View {
        VStack(alignment: .leading){
            HStack{
                if isAll {
                    Text(formatDate(date: trade.dateEntered))
                        .font(.footnote)
                        .opacity(0.5)
                }else{
                    Text(trade.dateEntered, style:  .time)
                        .font(.footnote)
                        .opacity(0.5)
                }
                Spacer()
                if trade.photoDirectory != nil {
                    Image(systemName: "photo")
                        .fixedSize()
                }
            }
            HStack{
//                if trade.isHindsight {
//                    Circle()
//                        .fill(.blue)
//                        .frame(width: 15, height: 15)
////                        .padding(.top)
//                }else{
//                    if trade.win!{
//                        Circle()
//                            .fill(.green)
//                            .frame(width: 15, height: 15)
////                            .padding(.top)
//                    }
//
//                    if trade.loss!{
//                        Circle()
//                            .fill(.red)
//                            .frame(width: 15, height: 15)
////                            .padding(.top)
//                    }
//                }
                Text(trade.symbol!.name + " @ " + myFormatter.numFormat(num: trade.entry))
//                    .padding([.top, .leading])
                Spacer()
                if showDot {
                        Circle()
                            .fill(trade.isHindsight ? .blue : trade.p_l == 0.0 ? .primary : trade.p_l > 0.0 ? .green : .red)
                            .frame(width: 15, height: 15)
                }else{
                    Text(myFormatter.numFormat(num: trade.p_l))
                        .foregroundColor(trade.isHindsight ? .blue : trade.p_l == 0.0 ? .primary : trade.p_l > 0.0 ? .green : .red)
                }
                
            }
            .padding([.top], 2)
//            Spacer()
//            VStack(alignment: .leading){
//
//              HStack{
//
//                  Text("Entry:")
//                      .bold()
//                  Text(myFormatter.numFormat(num: trade.entry) + " @")
//                  Text(trade.dateEntered, style: .time)
//
//              }
//              .padding([.bottom], 4)
//              HStack{
//                  Text("Exit:")
//                      .bold()
//                  Text(myFormatter.numFormat(num: trade.exit) + " @")
//                  Text(trade.dateExited, style: .time)
//              }
//
//
//
//            }
//            .padding()

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

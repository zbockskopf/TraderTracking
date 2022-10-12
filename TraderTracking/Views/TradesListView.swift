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
    @ObservedResults(Trade.self, filter: NSPredicate(format: "dateEntered BETWEEN {%@, %@}", Calendar.current.date(byAdding: .day, value: -7, to: Date())! as CVarArg, Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date())! as CVarArg), sortDescriptor: SortDescriptor(keyPath: "dateEntered", ascending: false)) var trades
    @ObservedResults(Account.self) var accounts
    @State var imageIsShown: Bool = false
    @State var tappedImageShown: Bool = false

    @State private var all: Bool?
    @State private var selectedTrade: Trade? = nil
    @State private var editSheet: Bool = false

    var calendar = Calendar.current
    var tradesPL: Decimal128 = 0.0
    var myFormatter = MyFormatter()
    var myImages = MyImages()

    var body: some View {
        NavigationStack{
            List {
                ForEach(0..<7){ i in
                    Section(header: headerDate(i: i)) {
                        ForEach(trades.filter("dateEntered BETWEEN {%@, %@}", dateChanger(date: Date(), i:i, isPrevDay: false), dateChanger(date: Date(), i:i, isPrevDay: true))){ t in
                            TradeRow(trade: t, selectedTrade: $selectedTrade, imageIsShown: $imageIsShown)
                                .onTapGesture {
//                                    if t.photoDirectory != nil {
//                                        selectedTrade = t
//                                    }
                                }
                                .swipeActions(edge: .leading, content: {
                                    Button {
                                        selectedTrade = t
                                    } label: {
                                        Label("", systemImage: "pencil")
                                    }
                                    .tint(.green)
                                })
                        }
                        .onDelete(perform: { t in
                            t.forEach{i in
                                if trades[i].photoDirectory != nil {
                                    realmController.myImage.deleteImage(fileName: trades[i].photoDirectory!)
                                }
                                realmController.updateAccountAfterTradeDelete(trade: trades[i])
                                $trades.remove(trades[i])
                                realmController.getWinRate()
                            }
                        })


                    }
                }

            }
            .fullScreenCover(item: $selectedTrade){ t in
                NewTradeView(realmController: realmController, sheetAction: Binding.constant(nil), isEditing: true, trade: t, tradeID: t._id,
                             symbol: t.symbol!.name, dateEntered: t.dateEntered, entry: t.entry.stringValue, dateExited: t.dateExited, exit: t.exit.stringValue, positionSize: String(t.positionSize), selectedPositionType: t.positionType, selectedSession: t.session, stopLoss: t.stopLoss?.stringValue ?? "", takeProfit: t.takeProfit?.stringValue ?? "", isHindsight: t.isHindsight, fees: t.fees.stringValue, selectedImages: myImages.loadImageFromDiskWith(directory: t.photoDirectory ?? "") ?? []
                )
            }
//            .sheet(item: $selectedTrade) { t in
////                NavigationStack{
////                    ZStack{
////                        ImageUIView(isPresented: $tappedImageShown, images: getTappedImages(trade: s))
////                            .environmentObject(tradeListData)
////                            .edgesIgnoringSafeArea(.all)
////
////                    }
////                    .navigationBarItems(
////                        leading:
////                            Button(action: {
////                                selectedTrade = nil
////                            }, label: {
////                                Text("Cancel")
////                                    .foregroundColor(Color(UIColor.label))
////
////                            })
////                    )
////                    .toolbarBackground(Color(UIColor.secondarySystemBackground), for: .navigationBar)
////                }
//
//            }
            .navigationBarTitle("")
            .navigationBarItems(
//                leading:
//                    Button(action: {
//                        withAnimation(.easeInOut){
//                            self.all = true
//                            imageIsShown.toggle()
//                            tradeListData.showImageViewer.toggle()
//                        }
//                    }, label: {
//                        Text("Study")
//                            .frame(minWidth: 0, maxWidth: 50)
//                            .font(.system(size: 10))
//                            .padding()
//                            .foregroundColor(Color(UIColor.label))
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 25)
//                                    .stroke(Color.green, lineWidth: 2)
//                        )
//                    })
//                    .fullScreenCover(isPresented: $imageIsShown, onDismiss: {
//                        self.all = nil
//                    }, content: {
//                        NavigationStack{
//                            ZStack{
//                                if getImages(all: true, trade: nil).count == 0 {
//                                    Text("No Photos")
//                                }else{
//
//                                    ImageUIView(isPresented: $imageIsShown, images: getImages(all: all ?? false, trade: selectedTrade ))
//                                        .environmentObject(tradeListData)
//                                        .edgesIgnoringSafeArea(.all)
//                                }
//
//                            }
//                            .navigationBarItems(
//                                leading:
//                                    Button(action: {
//                                        imageIsShown.toggle()
//                                    }, label: {
//                                        Text("Cancel")
//                                            .foregroundColor(Color(UIColor.label))
//
//                                    })
//                            )
//                            .toolbarBackground(Color(UIColor.secondarySystemBackground), for: .navigationBar)
//                        }
//                    }),
//                    .foregroundColor(Color.black)
                trailing:
                    Text(getTradesPL())
                    .foregroundColor(.primary)
            )

        }
    }

    func getTradesPL() -> String {
        var temp: Decimal128 = 0.0
        for i in trades {
            temp += i.p_l
            temp -= i.fees
        }
        return myFormatter.numFormat(num: temp)
    }



    func getImages(all: Bool, trade: Trade?) -> [IFImage] {
        var temp: Results<Trade>

        if all {
            temp = trades.filter("dateEntered BETWEEN {%@, %@}",Calendar.current.date(byAdding: .day, value: -7, to: Date())!, Date())
        }else{
            temp = trades.filter("dateEntered BETWEEN {%@, %@}",calendar.startOfDay(for: trade!.dateEntered), calendar.date(bySettingHour: 23, minute: 59, second: 59, of: trade!.dateEntered)!)
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

		@ViewBuilder
		func headerDate(i: Int) -> some View {
				if i == 0 {
						Text("Today")
				}else{
					Text(calendar.date(byAdding: .day, value: -i, to: Date())!, style: .date)
				}
		}

    func dateChanger(date: Date, i: Int, isPrevDay: Bool) -> Date {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -i, to: date)!)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: calendar.date(byAdding: .day, value: -i, to: date)!)
        if !isPrevDay{
            return startOfDay
        }else{
            return endOfDay!
        }
    }
}

struct TradeRow: View {
    var trade: Trade
    @Binding var selectedTrade: Trade?
    @Binding var imageIsShown: Bool

    var myFormatter = MyFormatter()

    var body: some View {
        VStack(alignment: .leading){
            Text(trade.dateEntered, style: .time)
                .font(.footnote)
                .opacity(0.5)
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
                Text(myFormatter.numFormat(num: trade.p_l))
                    .foregroundColor(trade.isHindsight ? .blue : trade.p_l == 0.0 ? .primary : trade.p_l > 0.0 ? .green : .red)
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

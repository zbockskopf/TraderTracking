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
    @ObservedResults(Trade.self) var trades
    @State var imageIsShown: Bool = false
    @State var tappedImageShown: Bool = false
    
    @State private var all: Bool?
    @State private var selectedTrade: Trade? = nil
    
    var calendar = Calendar.current
    
    var body: some View {
        NavigationStack{
            List {
                ForEach(0..<7){ i in

                    Section(header: Text(calendar.date(byAdding: .day, value: -i, to: Date())!, style: .date)){
                        
                        ForEach(trades.filter("dateEntered BETWEEN {%@, %@}", dateChanger(date: Date(), i:i, isPrevDay: false), dateChanger(date: Date(), i:i, isPrevDay: true))) { t in
                            TradeRow(trade: t, selectedTrade: $selectedTrade, imageIsShown: $imageIsShown)

                                .onTapGesture {
                                    selectedTrade = t
                                }
                        }
                        .onDelete(perform: { t in
                            t.forEach { i in
                                realmController.myImage.deleteImage(fileName: trades[i].photoDirectory!)
                                $trades.remove(trades[i])
                            }
                            
                        })
                        .swipeActions(edge: .leading, content: {
                            Button {
//                                editSheet.toggle()
                            } label: {
                                Label("", systemImage: "pencil")
                            }
                            .tint(.green)

                        })
                        
                    }
                }
                
            }
            .fullScreenCover(item: $selectedTrade) { s in
                NavigationStack{
                    ZStack{
                        ImageUIView(isPresented: $tappedImageShown, images: getTappedImages(trade: s))
                            .environmentObject(tradeListData)
                            .edgesIgnoringSafeArea(.all)
//                            .onAppear{
//                                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
//
//                                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
//                            }
//                            .onDisappear{
//                                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
////                                AppDelegate.orientationLock = .portrait
//                            }

                    }
                    .navigationBarItems(
                        leading:
                            Button(action: {
                                selectedTrade = nil
                            }, label: {
                                Text("Cancel")
                                    .foregroundColor(Color(UIColor.label))
                                
                            })
                    )
                    .toolbarBackground(Color(UIColor.secondarySystemBackground), for: .navigationBar)
                }

            }
            .navigationBarTitle("")
            .navigationBarItems(
                trailing:
                    Button(action: {
                        withAnimation(.easeInOut){
                            self.all = true
                            imageIsShown.toggle()
                            tradeListData.showImageViewer.toggle()
                        }
                    }, label: {
                        Text("Study")
                            .frame(minWidth: 0, maxWidth: 50)
                            .font(.system(size: 10))
                            .padding()
                            .foregroundColor(Color(UIColor.label))
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.green, lineWidth: 2)
                        )
//                            Image(systemName: "plus.circle.fill")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 40, height: 40)
//                                .clipShape(Circle())
                                
                    })
                    .fullScreenCover(isPresented: $imageIsShown, onDismiss: {
                        self.all = nil
                    }, content: {
                        NavigationStack{
                            ZStack{
                                if getImages(all: true, trade: nil).count == 0 {
                                    Text("No Photos")
                                }else{
                                    
                                    ImageUIView(isPresented: $imageIsShown, images: getImages(all: all ?? false, trade: selectedTrade ))
                                        .environmentObject(tradeListData)
                                        .edgesIgnoringSafeArea(.all)
//                                        .onAppear{
//                                            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation") // Forcing the rotation to portrait
//                                            AppDelegate.orientationLock = .landscape // And making sure it stays that way
//                                        }
//                                        .onDisappear{
//                                            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
//                                            AppDelegate.orientationLock = .portrait
//                                        }
                                }
                                
                            }
                            .navigationBarItems(
                                leading:
                                    Button(action: {
                                        imageIsShown.toggle()
                                    }, label: {
                                        Text("Cancel")
                                            .foregroundColor(Color(UIColor.label))
                                        
                                    })
                            )
                            .toolbarBackground(Color(UIColor.secondarySystemBackground), for: .navigationBar)
                        }
                    })
//                    .foregroundColor(Color.black)
            )

        }
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
            HStack{
                if trade.isHindsight {
                    Circle()
                        .fill(.blue)
                        .frame(width: 20, height: 20)
                        .padding(.top)
                }else{
                    if trade.win!{
                        Circle()
                            .fill(.green)
                            .frame(width: 20, height: 20)
                            .padding(.top)
                    }
                    
                    if trade.loss!{
                        Circle()
                            .fill(.red)
                            .frame(width: 20, height: 20)
                            .padding(.top)
                    }
                }
                Text(trade.symbol!.name)
                    .padding([.top, .leading])
                Spacer()

            }
            Spacer()
            VStack(alignment: .leading){
                
              HStack{
                  
                  Text("Entry:")
                      .bold()
                  Text("$" + String(myFormatter.numFormat(num: trade.entry)) + " @")
                  Text(trade.dateEntered, style: .time)

              }
              .padding([.bottom], 4)
              HStack{
                  Text("Exit:")
                      .bold()
                  Text("$" + String(myFormatter.numFormat(num: trade.exit)) + " @")
                  Text(trade.dateExited, style: .time)
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
                
//                Text((Date()), style: .time)
//                    .padding(.top)
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

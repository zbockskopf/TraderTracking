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
    @Binding var imageIsShown: Bool
    
    @State private var dateOne: Date?
    @State private var dateTwo: Date?
    @State private var all: Bool?
    var calendar = Calendar.current
    
//    var index: Int

    var body: some View {
        NavigationStack{
            List {
                ForEach(0..<7){ i in

                    Section(header: Text(calendar.date(byAdding: .day, value: -i, to: Date())!, style: .date)){
                        
                        ForEach(trades.filter("dateEntered BETWEEN {%@, %@}", dateChanger(date: Date(), i:i, isPrevDay: false), dateChanger(date: Date(), i:i, isPrevDay: true))) { t in
                            TradeRow(symbol: t.symbol!.name, date: t.dateEntered, entry: String(t.entry), exit: String(t.exit), win: t.win!, loss: t.loss!, hindsight: t.isHindsight)
                                .onTapGesture {
                                        self.all = true
                                        self.dateOne = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -i, to: t.dateEntered)!)
                                        self.dateTwo = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: calendar.date(byAdding: .day, value: -i, to: t.dateEntered)!)
                                    imageIsShown.toggle()
                                   
                                }
                        }

                        .onDelete(perform: { t in
                            t.forEach { i in
                                realmController.myImage.deleteImage(fileName: trades[i].photoDirectory!)
                                $trades.remove(trades[i])
                            }
                            
                        })
                    }
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
                        self.dateOne = nil
                        self.dateTwo = nil
                    }, content: {
                        NavigationStack{
                            ZStack{
                                if getImages(all: true, dateOne: nil, dateTwo: nil).count == 0 {
                                    Text("No Photos")
                                }else{
                                    
                                    ImageUIView(isPresented: $imageIsShown, images: getImages(all: all ?? false, dateOne: dateOne, dateTwo: dateTwo))
                                        .environmentObject(tradeListData)
                                        .edgesIgnoringSafeArea(.all)
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
    
    func getImages(all: Bool, dateOne: Date?, dateTwo: Date?) -> [IFImage] {
        var temp: Results<Trade>
        
        if all {
            temp = trades.filter("dateEntered BETWEEN {%@, %@}",Calendar.current.date(byAdding: .day, value: -7, to: Date())!, Date())
        }else{
            temp = trades.filter("dateEntered BETWEEN {%@, %@}",dateOne!, dateTwo!)
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
    var symbol: String
    var date: Date
    var entry: String
    var exit: String
    var win: Bool
    var loss: Bool
    var hindsight: Bool
//    var photos: UIImage?

    var body: some View {
        VStack(alignment: .leading){
            HStack{
//                Image(uiImage: photos!)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 40, height: 40)
              Text(symbol)
                  .padding()
              VStack{
                Text("Entry:")

                Text(entry)

              }
              .padding()

              VStack{
                  Text("Exit:")
                  Text(exit)
              }
              .padding()


            }


        HStack{
            HStack{
                Text(date, style: .date)
                Text(date, style: .time)
            }
            if win{
                Circle()
                    .fill(.green)
                    .frame(width: 20, height: 20)
            }

            if loss{
                Circle()
                    .fill(.red)
                    .frame(width: 20, height: 20)
            }
            
            if hindsight {
                Circle()
                    .fill(.blue)
                    .frame(width: 20, height: 20)
            }
        }
      }

    }
}

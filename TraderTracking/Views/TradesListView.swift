//
//  TradesListView.swift
//  TraderTracking
//
//  Created by Zach on 9/15/22.
//

import SwiftUI
import RealmSwift


struct TradesListView: View {
    
    @EnvironmentObject var realmController: RealmController
    @EnvironmentObject var tradeListData: TradeListViewModel
    @ObservedResults(Trade.self) var trades
    
    
//    var index: Int

    var body: some View {
        NavigationView{
            List {
                ForEach(0..<7){ i in

                    Section(header: Text(dateChanger(date: Date(), i:i), style: .date)){
                        
                        ForEach(trades.filter("dateEntered < %@", dateChanger(date: Date(), i:i))){ t in
                            TradeRow(date: t.dateEntered, entry: String(t.entry), exit: String(t.exit), win: t.win!, loss: t.loss!, photos: realmController.myImage.loadImageFromDiskWith(fileName: t.photos!))
                        }

                        .onDelete(perform: { t in
                            t.forEach { i in
                                realmController.myImage.deleteImage(fileName: trades[i].photos!)
                                $trades.remove(trades[i])
                            }
                            
                        })
                    }
                }
                
            }
            .navigationBarTitle("")
            .navigationBarItems(
                leading:
                    Button(action: {
                        withAnimation(.easeInOut){
                            tradeListData.showImageViewer.toggle()
                            
                        }
                    }, label: {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                
                    })
                    .foregroundColor(Color.black)
            )
            .onAppear{
                tradeListData.getImages()
            }
        }
    }
    
    func dateChanger(date: Date, i: Int) -> Date {
        let modifiedDate = Calendar.current.date(byAdding: .day, value: -(i), to: date)!
        return modifiedDate
    }
}

struct TradeRow: View {
//    var symbol: String
    var date: Date
    var entry: String
    var exit: String
    var win: Bool
    var loss: Bool
    var photos: Image?

    var body: some View {
        VStack(alignment: .leading){
            HStack{
                photos?
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
              Text("MES")
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
        }
      }

    }
}

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
    
//    var index: Int

    var body: some View {
        NavigationStack{
            List {
                ForEach(0..<7){ i in

                    Section(header: Text(dateChanger(date: Date(), i:i), style: .date)){
                        
                        ForEach(trades.filter("dateEntered < %@", dateChanger(date: Date(), i:i))){ t in
                            TradeRow(symbol: t.symbol!.name, date: t.dateEntered, entry: String(t.entry), exit: String(t.exit), win: t.win!, loss: t.loss!, photos: realmController.myImage.loadImageFromDiskWith(fileName: t.photos!))
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
                trailing:
                    Button(action: {
                        withAnimation(.easeInOut){
                            imageIsShown.toggle()
                            tradeListData.showImageViewer.toggle()
                        }
                    }, label: {
                        Text("Study")
                            .frame(minWidth: 0, maxWidth: 50)
                            .font(.system(size: 10))
                            .padding()
                            .foregroundColor(.white)
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
                    .fullScreenCover(isPresented: $imageIsShown, content: {
                        NavigationStack{
                            ZStack{
                                if getImages().count == 0 {
                                    Text("No Photos")
                                }else{
                                    ImageUIView(isPresented: $imageIsShown, images: getImages())
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
    
    func getImages() -> [IFImage] {
        let temp = trades.filter("dateEntered BETWEEN {%@, %@}",Calendar.current.date(byAdding: .day, value: -7, to: Date())!, Date())
        var images: [IFImage] = []
        for i in temp{
            if i.photos != nil{
                images.append(IFImage(image: RealmController.shared.myImage.loadImageFromDiskWith(fileName: i.photos!)!))
            }
        }
        return images
    }
    
    func dateChanger(date: Date, i: Int) -> Date {
        let modifiedDate = Calendar.current.date(byAdding: .day, value: -(i), to: date)!
        return modifiedDate
    }
}

struct TradeRow: View {
    var symbol: String
    var date: Date
    var entry: String
    var exit: String
    var win: Bool
    var loss: Bool
    var photos: UIImage?

    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Image(uiImage: photos!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
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
        }
      }

    }
}

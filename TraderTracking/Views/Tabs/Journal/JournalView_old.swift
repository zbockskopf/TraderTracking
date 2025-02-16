//
//  JournalView.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 9/24/23.
//

import Foundation
import SwiftUI
import RealmSwift
import ImageUI
import PhotosUI


//struct JournalView: View {
//    @EnvironmentObject var realmController: RealmController
//    
//    @State var weekNumber: String
//    
//    @State var showNewWeeklyForecast: Bool = false
//    @State var showNewWeeklyReview: Bool = false
//    @State var showNewDailyForecast: Bool = false
//    @State var showNewDailyReview: Bool = false
//    
//    var myFormatter = MyFormatter()
//    
//    var body: some View{
//        NavigationStack{
//            List{
//                ForEach(0...1, id:\.self){n in
//                    if n == 0{
//                        NavigationLink("Forecast"){
//                            ForecastViewRow(date: Date())
//                        }
//                    }else{
//                        NavigationLink("Review"){
//                            ReviewViewRow(date: Date())
//                        }
//                    }
//                }
//                ForEach(Date().tradeListWeekDates, id: \.self){ date in
//                    Section(header: myFormatter.dayOfWeek(date: date)){
//                        ForEach(0...1, id:\.self){n in
//                            if n == 0{
//                                NavigationLink("Forecast"){
//                                    ForecastViewRow(date: date)
//                                }
//                            }else{
//                                NavigationLink("Review"){
//                                    ReviewViewRow(date: date)
//                                }
//                            }
//                        }
//                    }
//                    .onAppear(perform: {
//                        UITableView.appearance().sectionFooterHeight = 0
//                    })
//                }
//            }
//            // Weekly Forecast
//            .sheet(isPresented: $showNewWeeklyForecast, content: {
//                NewForecast(type: .week)
//            })
//            // Weekly Review
//            .sheet(isPresented: $showNewWeeklyReview, content: {
//                NewForecast(type: .week)
//            })
//            //Daily Forecast
//            .sheet(isPresented: $showNewDailyForecast, content: {
//                NewForecast(type: .day)
//            })
//            //DailyReview
//            .sheet(isPresented: $showNewDailyReview, content: {
//                NewForecast(type: .day)
//            })
//            
//            .toolbar{
//                ToolbarItemGroup(placement: .navigationBarTrailing){
//                    Menu {
//                        Menu {
//                            Button {
//                                showNewWeeklyForecast.toggle()
//                            } label: {
//                                Text("New Week Forecast")
//                            }
//                            
//                            Button {
//                                showNewWeeklyReview.toggle()
//                            } label: {
//                                Text("New Weekly Review")
//                            }
//                        } label: {
//                            Text("Weekly")
//                        }
//                        
//                        Menu {
//                            Button {
//                                showNewDailyForecast.toggle()
//                            } label: {
//                                Text("New Daily Forecast")
//                            }
//                            
//                            Button {
//                                showNewDailyReview.toggle()
//                            } label: {
//                                Text("New Daily Review")
//                            }
//                        } label: {
//                            Text("Daily")
//                        }
//
//                    } label: {
//                        Image(systemName: "plus.circle")
//                            .foregroundStyle(Color.green)
//                    }
//
//                }
//            }
//            .navigationTitle(weekNumber)
//            .navigationBarTitleDisplayMode(.automatic)
//        }
//        
//
//    }
//}
//
//struct ForecastViewRow: View{
//    @State var date: Date
//    var myFormatter = MyFormatter()
//    var body: some View{
//        Text(myFormatter.formateHeaderDate(date: date))
//    }
//}
//
//struct ReviewViewRow: View{
//    @State var date: Date
//    var myFormatter = MyFormatter()
//    var body: some View{
//        Text(myFormatter.formateHeaderDate(date: date))
//    }
//}
//

//
//struct NewForecast: View {
//    @State var type: ForecastType
//    @State var notes: String = ""
//    var body: some View {
//        Form{
//            Text(type.localizedName)
//            TextEditor(text: $notes)
//        }
//        
//    }
//}


//enum ForecastType: String, Equatable, CaseIterable, PersistableEnum  {
//    case week = "Week"
//    case day = "Day"
//    case none = "none"
//
//    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
//}
//
//struct JournalView: View {
//    @EnvironmentObject var realmController: RealmController
//    @State private var showNewForecast = false
//    @State private var selectedForecastType: ForecastType = .week
//    @State private var notes = ""
//    
//    @State var weekNumber: String
//    var myFormatter = MyFormatter()
//    
//    var headerText: [String] = ["Forecast", "Review"]
//    
//    @State var selectedImage: Int = 0
//    @State var imageIsShown: Bool = false
//    @State var photos: [Image] = [Image("daily"),Image("4h"),Image("1h")]
//    
//    @State var sectionsExtended: [Bool] = Array(repeating: false, count: Date().tradeListWeekDates.count)
//
//    
//    var body: some View {
//        NavigationStack {
//            List {
//                ForEach(headerText, id:\.self){i in
//                    JournalHeaderRow(text: i)
//                    JournalNoteRow(text: "testing to see how this looks")
//                }
//                ForEach(Date().tradeListWeekDates.reversed(), id: \.self){ date in
//                    @State var collasaped: Bool = false
//                    JournalDivider()
//                    Section(header: myFormatter.dayOfWeek(date: date)){
//                        ForEach(headerText, id:\.self){i in
//                            JournalHeaderRow(text: i)
//                            JournalNoteRow(text: "testing to see how this looks. Need to make this a long string so it can go maore than one line. Add in some random words cause this will do the trick!")
//                            JournalPhotoRow(selectedPhoto: $selectedImage, imageIsShown: $imageIsShown, photos: photos)
//                        }
//                    }
//
//                    .onAppear(perform: {
//                        UITableView.appearance().sectionFooterHeight = 0
//                    })
//                }
//            }
//            .sheet(isPresented: $showNewForecast) {
//                NewForecast(showSheet: $showNewForecast, selectedForecastType: $selectedForecastType)
//            }
//            .fullScreenCover(isPresented: $imageIsShown, content: {
//                ImageScrollView(images: photos)
//            })
////            .fullScreenCover(isPresented: $imageIsShown) {
////                NavigationStack{
////    //                    ZStack{
////                    IFBrowserView(images: convertImages(images: photos), selectedIndex: $selectedImage)
////                        .edgesIgnoringSafeArea(.all)
////                        .toolbar {
////                                    ToolbarItem(placement: .navigationBarLeading) {
////                                        Button(action: {
////                                            imageIsShown = false
////                                        }, label: {
////                                            Text("Back")
////                                        })
////                                    }
////
////                            ToolbarItem(placement: .navigationBarTrailing){
////                                HStack{
////                                    Button(action: {
////                                        imageIsShown = false
////                                    }, label: {
////
////                                            Image(systemName: "pencil.tip.crop.circle")
////                                    })
////
////    //                                ShareLink(item: Image(uiImage:images[selectedPhoto]), preview: SharePreview("", image: Image(uiImage:images[selectedPhoto])))
////                                }
////
////
////                            }
////                        }
//////                        .toolbarColorScheme(scheme == .light ? .light : .dark , for: .navigationBar)
////                          .toolbarBackground(.visible, for: .navigationBar)
////    //                ImageUIView(isPresented: $imageIsShown, images: convertImages(images: images))
////    //                        .environmentObject(tradeListData)
////    //                        .edgesIgnoringSafeArea(.all)
////
////    //                    }
////    //                .navigationBarItems(
////    //                    leading:
////    //                        Rectangle()
////    //                        .opacity(5)
////    //                        .background(.white)
////    //                        .overlay(
////    //                            Button(action: {
////    //                                imageIsShown.toggle()
////    //                            }, label: {
////    //                                Text("Cancel")
////    //                                    .foregroundColor(.primary)
////    //
////    //                            })
////    //                        )
////    //
////    //
////    //                )
////    //                .navigationBarTitleDisplayMode(.inline)
////
////                }
////                .toolbarBackground(Color(UIColor.green), for: .navigationBar)
////
////            }
//            .toolbar {
//                ToolbarItemGroup(placement: .navigationBarTrailing) {
//                                    Menu {
//                                        Menu{
//                                            forecastMenu(type: .week)
//                                            reviewMenu(type: .week)
//                                        } label: {
//                                            Text("Week")
//                                        }
//                                        Menu{
//                                            forecastMenu(type: .day)
//                                            reviewMenu(type: .day)
//                                        } label: {
//                                            Text("Day")
//                                        }
//                                        
//                                    } label: {
//                                        Image(systemName: "plus.circle")
//                                            .foregroundStyle(Color.green)
//                                    }
//                                }
//            }
//            .navigationTitle(weekNumber)
//        }
//    }
//    
//    
//    private func forecastMenu(type: ForecastType) -> some View {
//        Button {
//            selectedForecastType = type
//            showNewForecast.toggle()
//        } label: {
//            Text("New \(type.rawValue) Forecast")
//        }
//    }
//    
//    private func reviewMenu(type: ForecastType) -> some View {
//        Button {
//            selectedForecastType = type
//            showNewForecast.toggle()
//        } label: {
//            Text("New \(type.rawValue) Review")
//        }
//    }
//    
//    func convertImages(images: [Image]) -> [IFImage] {
//        var temp: [IFImage] = []
//
//  
//            for p in images {
//                temp.append(IFImage(image: p.asUiImage()))
//            }
////        temp.removeFirst()
//        return temp
//    }
//}
//
//struct ForecastViewRow: View{
//    @State var date: Date
//    var myFormatter = MyFormatter()
//    var body: some View{
//        Text(myFormatter.formateHeaderDate(date: date))
//    }
//}
//
//struct ReviewViewRow: View{
//    @State var date: Date
//    var myFormatter = MyFormatter()
//    var body: some View{
//        Text(myFormatter.formateHeaderDate(date: date))
//    }
//}
//
//struct JournalDivider: View{
//    var body: some View{
//        Divider()
//            .frame(maxWidth: .infinity)
//            .listRowBackground(Color.primary.opacity(0))
//            .listRowSeparator(.hidden)
//    }
//}
//
//struct NewForecast: View {
//    @Binding var showSheet: Bool
//    @Binding var selectedForecastType: ForecastType
//    @State private var notes = ""
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                Picker("Select Forecast Type", selection: $selectedForecastType) {
//                    ForEach(ForecastType.allCases, id: \.self) { type in
//                        Text(type.rawValue).tag(type)
//                    }
//                }
//                TextEditor(text: $notes)
//            }
//            .navigationTitle("New \(selectedForecastType.rawValue) Forecast")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Save") {
//                        // Handle saving here
//                        showSheet.toggle()
//                    }
//                }
//            }
//        }
//    }
//}



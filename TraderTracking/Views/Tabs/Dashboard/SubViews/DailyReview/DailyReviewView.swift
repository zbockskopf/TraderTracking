//
//  DailyReviewView.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 6/29/23.
//
import RealmSwift
import SwiftUI

struct DailyReviewView: View {
    @EnvironmentObject var menuController: MenuController
    @EnvironmentObject var realmController: RealmController
    @State var showAdd: Bool = false
    @ObservedObject private var viewModel: DailyReviewViewModel
    
    init(realm: Realm) {
        viewModel = DailyReviewViewModel(realm: realm)
    }
    
    var weekDayNames: [String] = ["Mon", "Tues", "Wed", "Thur", "Fri"]
    
    //    var body: some View {
    //        NavigationStack{
    //            
    //            List{
    //                ForEach(0...4, id: \.self){ i in
    //                    Section {
    //                        ForEach(viewModel.reviews) { model in
    //                            Text(model._id.stringValue)
    //                        }
    //                    } header: {
    //                        Text(weekDayNames[i])
    //                    }
    //                }
    //                
    //            }
    //            .sheet(isPresented: $showAdd, content: {
    //                AddDailyReviewView()
    //                    .environmentObject(realmController)
    //            })
    //            .toolbar{
    //                ToolbarItem(placement: .topBarTrailing) {
    //                    Button {
    //                        showAdd.toggle()
    //                    } label: {
    //                        Image(systemName: "plus")
    //                            .foregroundStyle(.green)
    //                    }
    //
    //                }
    //            }
    //        }
    //    }
    // Function to group DailyReview objects by day of the week
        func groupedDailyReviewsByDay() -> [String: [DailyReview]] {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE" // "EEEE" returns the day of the week (e.g., Monday, Tuesday, etc.)
            
            // Create a dictionary with all weekdays as keys and empty arrays as values
            var groupedReviews: [String: [DailyReview]] = [
                "Monday": [],
                "Tuesday": [],
                "Wednesday": [],
                "Thursday": [],
                "Friday": []
            ]
            
            // Group DailyReview objects by day of the week
            for review in viewModel.reviews {
                let day = dateFormatter.string(from: review.date)
                groupedReviews[day]?.append(review)
            }
            
            return groupedReviews
        }

        var body: some View {
            NavigationStack{
                
            
            List {
                ForEach(groupedDailyReviewsByDay().sorted(by: { $0.key < $1.key }), id: \.key) { day, dailyReviews in
                    Section(header: Text(day)) {
                        if dailyReviews.isEmpty {
                            Text("No Daily Reviews")
                        } else {
                            ForEach(dailyReviews) { dailyReview in
                                VStack(alignment: .leading) {
                                    Text("Date: \(formattedDate(from: dailyReview.date))")
                                    Text("URL: \(dailyReview.URL ?? "N/A")")
                                    Text("Notes: \(dailyReview.notes)")
                                }
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showAdd, content: {
                                AddDailyReviewView()
                                    .environmentObject(realmController)
                            })
            }
                .navigationTitle("Daily Reviews")
                .listStyle(InsetGroupedListStyle())
        }
    // Helper function to format the date as medium style
    func formattedDate(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
}

#Preview {
    DailyReviewView(realm: RealmController().realm)
}

//
//  JournalPagerViewModel.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 6/29/24.
//

import SwiftUI
import Combine
import RealmSwift

class JournalViewModel: ObservableObject {
    @ObservedResults(Trade_Journal.self, sortDescriptor: SortDescriptor(keyPath: "date", ascending: false)) var trades
    @ObservedResults(Forecast_Journal.self, sortDescriptor: SortDescriptor(keyPath: "date", ascending: false)) var forecasts
    @ObservedResults(Review_Journal.self, sortDescriptor: SortDescriptor(keyPath: "date", ascending: false)) var reviews

    
    // Add any other methods to manage your data
}

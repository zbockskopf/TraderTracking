//
//  Journal.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 7/4/24.
//

import SwiftUI

struct TabModel: Identifiable {
    private(set) var id: Tab
    var size: CGSize = .zero
    var minX: CGFloat = .zero
    
    enum Tab: String, CaseIterable {
        case forecast = "Forecasts"
        case reviews = "Reviews"
        case trades = "Trades"
    }
}

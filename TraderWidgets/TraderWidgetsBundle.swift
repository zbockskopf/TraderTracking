//
//  TraderWidgetsBundle.swift
//  TraderWidgets
//
//  Created by Zach Bockskopf on 1/7/24.
//

import WidgetKit
import SwiftUI

@main
struct TraderWidgetsBundle: WidgetBundle {
    var body: some Widget {
        TraderWidgets()
        TraderWidgetsLiveActivity()
    }
}

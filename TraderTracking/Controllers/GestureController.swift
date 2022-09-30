//
//  GestureController.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 9/30/22.
//

import Foundation
import SwiftUI

class GestureController: ObservableObject {
    @Published var xOffset: CGFloat = 0
    @Published var currentXOffset: CGFloat = 0
    @Published var gestureOffset: CGFloat = 0
    var screenWidth = UIScreen.main.bounds.width
    
    init(){
        xOffset = -screenWidth * 0.8
        currentXOffset = xOffset
    }
    
    func onChange() {
        let sideBarWidth = screenWidth * 0.8
        xOffset = (gestureOffset != 0) ? (gestureOffset + currentXOffset < sideBarWidth ? gestureOffset + currentXOffset : xOffset) : xOffset
    }
}

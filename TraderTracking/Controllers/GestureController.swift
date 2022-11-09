//
//  GestureController.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 10/14/22.
//

import Foundation
import SwiftUI


class GestureController: NSObject, ObservableObject {
    @Published var showMenu: Bool = false
    @Published var offSet: CGFloat = 0
    @Published var lastStoredOffset: CGFloat = 0
    @Published var showListView: Bool = false
    let sideBarWidth = UIScreen.main.bounds.width - 90
    
    func isShowMenuAndOffsetZero(){
        offSet = sideBarWidth
        lastStoredOffset = offSet
    }
    
    func isNotShowMenuAndOffSetSideBar() {
        offSet = 0
        lastStoredOffset = 0
        
    }
    
    func onChange(gestureOffset: CGFloat){
        
        offSet = (gestureOffset != 0) ? ((gestureOffset + lastStoredOffset) < sideBarWidth ? (gestureOffset + lastStoredOffset) : offSet) : offSet
        
        offSet = (gestureOffset + lastStoredOffset) > 0 ? offSet : 0
    }
    
    func onEnd(value: DragGesture.Value){
        
        
        let translation = value.translation.width
        
        withAnimation{
            // Checking...
            if translation > 0{
                
                if translation > (sideBarWidth / 2){
                    // showing menu...
                    offSet = sideBarWidth
                    showMenu = true
                }
                else{
                    
                    // Extra cases...
                    if offSet == sideBarWidth || showMenu{
                        return
                    }
                    offSet = 0
                    showMenu = false
                }
            }
            else{
                
                if -translation > (sideBarWidth / 2){
                    offSet = 0
                    showMenu = false
                }
                else{
                    
                    if offSet == 0 || !showMenu{
                        return
                    }
                    
                    offSet = sideBarWidth
                    showMenu = true
                }
            }
        }
        
        // storing last offset...
        lastStoredOffset = offSet
    }
}

//
//  ContentView.swift
//  TraderTracking
//
//  Created by Zach on 9/15/22.
//

import SwiftUI
import SwiftPieChart
import RealmSwift
import ConfettiSwiftUI

struct ContentView: View {

    @EnvironmentObject var realmController: RealmController
    @ObservedResults(Trade.self, filter: NSPredicate(format: "win = true AND isHindsight = false")) var wins
    @ObservedResults(Trade.self, filter: NSPredicate(format: "loss = true AND isHindsight = false")) var losses
    @ObservedResults(Symbol.self) var symbols

    @State private var confettiCounter: Int = 0
    @State private var showNewTrade = false
    @State private var sheetAction: SheetAction = SheetAction.nothing

    var screenWidth = UIScreen.main.bounds.width
    	
    @Binding var currentXOffset: CGFloat
    @Binding var xOffset: CGFloat
    @Binding var lastStoredOffset: CGFloat
    @GestureState var gestureOffset: CGFloat = 0
    @Environment(\.colorScheme) var scheme

    var body: some View {

        NavigationView{
            ZStack{
                VStack{
                    Text(realmController.winRate)
                        .font(.largeTitle)
                        .padding()
                    
                    HStack{
                        Spacer()
                        
                        VStack{
                            Text("Wins")
                            Text(String(wins.count))
                        }
                        .foregroundColor(Color(UIColor.label))
                        
                        Spacer()
                        
                        VStack{
                            Text("Losses")
                            Text(String(losses.count))
                        }
                        .foregroundColor(Color(UIColor.label))
                        
                        Spacer()
                    }
                    .padding()
                    
                    
                    
                    VStack{
                        Button(action: {
                            showNewTrade.toggle()
                        }) {
                            Text("New Trade")
                                .frame(minWidth: 0, maxWidth: 200)
                                .font(.system(size: 18))
                                .padding()
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.green, lineWidth: 2)
                                )
                        }
                        .background(Color.green)
                        .cornerRadius(25)
                        .confettiCannon(counter: $confettiCounter)
                        .sheet(isPresented: $showNewTrade, onDismiss: {
                            delayConfetti(sheetAction: sheetAction, realmController: realmController)
                        }){
                            NewTradeView(realmController: realmController, sheetAction: $sheetAction)
                        }
                        
                    }
                    .padding()
                }
                (scheme == .light ? Color.black : Color.white).opacity(0.3)
                    .opacity(xOffset == 0 ? 0.7 : 0)
                    .ignoresSafeArea()
                    .allowsHitTesting(xOffset == 0 ? true : false)
                    .onTapGesture {
                        withAnimation {
                            xOffset = -screenWidth * 0.8
                        }
                    }
            }
            .navigationBarTitle("")
            .navigationBarItems(
                leading:
                    Button(action: {
                        withAnimation{
                            xOffset = 0
                        }
                    }, label: {
                        if xOffset == -screenWidth * 0.8 {
                            Image("Profile")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        }
                    })
            )

        }
        .frame(
              minWidth: 0,
              maxWidth: .infinity,
              minHeight: 0,
              maxHeight: .infinity
            )
        .gesture(
            DragGesture()
                .updating($gestureOffset, body: { value, out, _ in
                    
                    out = value.translation.width
                })
                .onEnded(onEnd(value:))
            )
        .animation(.easeOut, value: offset == 0)
                .onChange(of: showMenu) { newValue in
                    let sideBarWidth = -screenWidth * 0.8
                    if showMenu && offset == 0 {
                        offset = sideBarWidth
                        lastStoredOffset = xOffset
                    }
                    
                    if !showMenu && xOffset == sideBarWidth {
                        offset = 0
                        lastStoredOffset = 0
                    }
                }
                .onChange(of: gestureOffset) { newVaule in
                    onChange()
                }
//            DragGesture()
//                .onChanged({ value in
//                    if value.startLocation.x < CGFloat(100.0){
//                        if value.translation.width > 0 && xOffset != 0 { // left to right
//                            withAnimation {
//                                xOffset = currentXOffset + value.translation.width
//                            }
//                        } else if value.translation.width < 0 && xOffset != -screenWidth * 0.8 {
//                            withAnimation {
//                                xOffset = currentXOffset + value.translation.width
//                            }
//                        }
//                    }
//                })
//                .onEnded({ value in
//                    if value.translation.width > 0 { // left to right
//                        withAnimation {
//                            xOffset = 0
//                        }
//                    } else {
//                        withAnimation {
//                            xOffset = -screenWidth * 0.8
//                        }
//                    }
//                    currentXOffset = xOffset
//                })
//        )
    }
            
            
    func onChange() {
            let sideBarWidth = -screenWidth * 0.8
            xOffset = (gestureOffset != 0) ? (gestureOffset + lastStoredOffset < sideBarWidth ? gestureOffset + lastStoredOffset : xOffset) : xOffset
        }
        
            func onEnd(value: DragGesture.Value) {
                    let sideBarWidth = -screenWidth * 0.8
                    
                    let translation = value.translation.width
                    
                    if translation > 0 {
                        if translation > (sideBarWidth / 2){
                            xOffset = sideBarWidth
                        }else{
                            xOffset = 0

                        }
                    }else{
                        if -translation > (sideBarWidth / 2){
                            xOffset = 0
                        }else{

                            xOffset = sideBarWidth

                        }
                    }
                    
                    lastStoredOffset = xOffset
                }


    private func delayConfetti(sheetAction: SheetAction, realmController: RealmController) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//          add swtich here for sheetAction
            switch sheetAction {
            case .nothing, .loss, .cancel:
                break
            case .win:
                confettiCounter += 1
            case .done:
                break
            }
            self.sheetAction = .nothing
        }
    }

}

enum SheetAction {
    case nothing
    case loss
    case win
    case cancel
    case done
}


struct ProfileView: View {
    var body: some View {
        Image("Profile")
            .resizable()
            .scaledToFit()
            .frame(width: 55, height: 55)
            .clipShape(Circle())
    }
}

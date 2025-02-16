//
//  StatsView.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 1/18/23.
//

import SwiftUI

struct SideMenuStats: View {
    @EnvironmentObject var realmController: RealmController
    @EnvironmentObject var menuController: MenuController
    @StateObject var controller: StatsController = StatsController()
    var body: some View {
        VStack(alignment: .listRowSeparatorLeading){
            weeklyGoal()
                .padding(.bottom, 10)
            last50percent()
                .padding(.bottom, 10)
            streak()
                .padding(.bottom, 10)
            HStack{
                Text("Average RR")
                    .bold()
                Spacer()
                Text(String(controller.averageRR))
            }.padding(.bottom, 10)
        }
        .environmentObject(realmController)
        .environmentObject(menuController)
        .onAppear{
            controller.refreshRR()
        }
    }
}

struct weeklyGoal: View {
    @EnvironmentObject var realmController: RealmController
    @EnvironmentObject var menuController: MenuController
    
    @State var weeklyGoalValue: String = ""
    var body: some View {
        HStack{
            Text("Weekly Goal:")
                .bold()
            Spacer()
            Text(realmController.account.curWeeklyGoal.stringValue + " / " + String(realmController.account.weeklyGoal))
                .onTapGesture {
                    menuController.showWeeklyGoalAlert.toggle()
                }
                .alert("Weekly Goal", isPresented: $menuController.showWeeklyGoalAlert, actions: {
                    TextField("", text: $weeklyGoalValue)
                        .keyboardType(.decimalPad)
                    
                    Button("Set", role: .destructive ,action: {
                        realmController.setWeeklyGoal(newVal: weeklyGoalValue)
                    })
                        .foregroundColor(.red)
                    Button("Cancel", role: .cancel, action:{})
                }, message: {
                    Text("")
                })
        }
    }
}

struct last50percent: View {
    @EnvironmentObject var realmController: RealmController
    var myFormatter = MyFormatter()
    var body: some View{
        HStack{
            Text("% Last 50")
                .bold()
            Spacer()
            if realmController.account.trades.filter("isHindsight = false AND isDeleted = false").count >= 49{
                Text(String(myFormatter.percentFormat(num: Double(Double(realmController.account.trades.filter("isHindsight = false AND isDeleted = false").suffix(50).filter{$0.win == true}.count) / Double(realmController.account.trades.filter("isHindsight = false AND isDeleted = false").suffix(50).count)) )))
            }else{
                Text("0")
            }
        }

    }
}

struct streak: View{
    @EnvironmentObject var realmController: RealmController
    var body: some View{
        HStack{
            Text("Streak")
                .bold()
            Spacer()
            Text(String(realmController.streak))
        }
    }
}


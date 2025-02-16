//
//  NotificationSettings.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 9/29/22.
//

import SwiftUI

struct NotificationSettings: View {
    @EnvironmentObject var notifications: MyNotifications
    @EnvironmentObject var menuController: MenuController
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    @AppStorage( "checkForexCalendar") var checkForexCalendar: Bool = false
    @AppStorage( "2:40 Marco") var twoFortyMarco: Bool = false
    @AppStorage( "TradingPlan") var tradingPlan: Bool = false
    @AppStorage( "OpeningBell") var openingBell: Bool = false
    @AppStorage( "COTRelease") var COTRelease: Bool = false
    
    var body: some View {
        List{
            if UserDefaults.standard.bool(forKey: "personalDevice"){
                ForexCalendarNotificationSetting(checkForexCalendar: $checkForexCalendar)
                TwoFortyMacroNotificationSetting(twoFortyMarco: $twoFortyMarco)
                TradingPlanNotificationSetting(tradingPlan: $tradingPlan)
                OpeningBellSetting(openingBell: $openingBell)
                COTReleaseSetting(COTRelease: $COTRelease)
            }else{
                ForexCalendarNotificationSetting(checkForexCalendar: $checkForexCalendar)
                OpeningBellSetting(openingBell: $openingBell)
            }

        }
        .environmentObject(notifications)
        .onAppear{
            menuController.showListView = true
        }
        .onDisappear{
            menuController.showListView = false
        }
    }
}

struct ForexCalendarNotificationSetting: View {
    
    @EnvironmentObject var notifications: MyNotifications
    @Binding var checkForexCalendar: Bool
    
    var body: some View{
        Toggle(isOn: $checkForexCalendar) {
            Text("Forex Calendar")
        }
        .onChange(of: checkForexCalendar) { newValue in
            if newValue{
                notifications.forexCalendarReminder()
            }else{
                notifications.clearCalendarReminder()
            }
        }
        
        if checkForexCalendar{
            HStack{
                Spacer()
                Text("Time")
                DatePicker("", selection: $notifications.notificationTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
            }
        }
    }
}

struct TwoFortyMacroNotificationSetting: View {
    @EnvironmentObject var notifications: MyNotifications
    @Binding var twoFortyMarco: Bool
    var body: some View {
        Toggle(isOn: $twoFortyMarco) {
                        Text("2:40 Marco")
                    }
        .onChange(of: twoFortyMarco) { newValue in
            if newValue{
                notifications.twoFortyMarco()
            }else{
                notifications.clear240Macro()
            }
        }
        if twoFortyMarco{
            HStack{
                Spacer()
                Text("Time")
                DatePicker("", selection: $notifications.notification240Time, displayedComponents: .hourAndMinute)
                            .labelsHidden()
            }
        }
    }
}

struct TradingPlanNotificationSetting: View {
    @EnvironmentObject var notifications: MyNotifications
    @Binding var tradingPlan: Bool
    var body: some View{
        Toggle(isOn: $tradingPlan) {
                        Text("Trading Plan")
                    }
        .onChange(of: tradingPlan) { newValue in
            if newValue{
                notifications.tradingPlan()
            }else{
                notifications.clearTradingPlan()
            }
        }
        if tradingPlan{
            HStack{
                Spacer()
                Text("Time")
                DatePicker("", selection: $notifications.tradingPlanTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
            }
        }

    }
}

struct OpeningBellSetting: View {
    @EnvironmentObject var notifications: MyNotifications
    @Binding var openingBell: Bool
    var body: some View{
        Toggle(isOn: $openingBell) {
                        Text("Opening Bell")
                    }
        .onChange(of: openingBell) { newValue in
            if newValue{
                notifications.openingBell()
            }else{
                notifications.clearOpeningBell()
            }
        }
        if openingBell{
            HStack{
                Spacer()
                Text("Time")
                DatePicker("", selection: $notifications.openingBellTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
            }
        }
    }
}

struct COTReleaseSetting: View {
    @EnvironmentObject var notifications: MyNotifications
    @Binding var COTRelease: Bool
    var body: some View{
        Toggle(isOn: $COTRelease) {
                        Text("COT Release")
                    }
        .onChange(of: COTRelease) { newValue in
            if newValue{
                notifications.COTRelease()
            }else{
                notifications.clearCOTRelease()
            }
        }
        if COTRelease{
            HStack{
                Spacer()
                Text("Time")
                DatePicker("", selection: $notifications.COTReleaseTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
            }
        }
    }
}


struct NotificationSettings_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettings()
    }
}

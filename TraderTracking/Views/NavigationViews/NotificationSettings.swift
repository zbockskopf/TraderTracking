//
//  NotificationSettings.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 9/29/22.
//

import SwiftUI

struct NotificationSettings: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @AppStorage( "checkForexCalendar") var checkForexCalendar: Bool = false
//    @AppStorage ("checkForexCalendarTime") var checkForexCalendarTime: Date?
    let notification = Notifications()
    var body: some View {
        List{
            Toggle(isOn: $checkForexCalendar) {
                Text("Forex Calendar")
            }
            .onChange(of: checkForexCalendar) { newValue in
                if newValue{
                    notification.forexCalendarReminder()
                }else{
                    notification.clearNotification()
                }
                
            }
            
            if checkForexCalendar{
                HStack{
                    Text("Time")
                   
                }
            }
        }
        
    }
}

struct NotificationSettings_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettings()
    }
}

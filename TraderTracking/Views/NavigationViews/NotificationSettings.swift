//
//  NotificationSettings.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 9/29/22.
//

import SwiftUI

struct NotificationSettings: View {
    @EnvironmentObject var notifications: Notifications
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @AppStorage( "checkForexCalendar") var checkForexCalendar: Bool = false
//    @AppStorage ("checkForexCalendarTime") var checkForexCalendarTime: Date?
    var body: some View {
        List{
            Toggle(isOn: $checkForexCalendar) {
                Text("Forex Calendar")
            }
            .onChange(of: checkForexCalendar) { newValue in
                if newValue{
                    notifications.forexCalendarReminder()
                }else{
                    notifications.clearNotification()
                }
                
            }
            
            if checkForexCalendar{
                HStack{
                    Text("Time")
                    Spacer()
                    DatePicker("", selection: $notifications.notificationTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
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

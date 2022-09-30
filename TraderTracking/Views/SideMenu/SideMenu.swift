//
//  SideMenu.swift
//  TraderTracking
//
//  Created by Zach on 9/16/22.
//

import SwiftUI

struct SideMenu: View {
    @EnvironmentObject var realmController: RealmController
    @EnvironmentObject var notifications: Notifications
    let calendarPublisher = NotificationCenter.default.publisher(for: NSNotification.Name("ForexCalendar"))
    var screenWidth = UIScreen.main.bounds.width
    @Binding var currentXOffset: CGFloat
    @Binding var xOffset: CGFloat
    
    @State private var showDeleteAlert: Bool = false
    @State private var showForexCalendar: Bool = false
    @Binding var showNotificationSettings: Bool
    @Binding var showProfile: Bool
    
    var body: some View {
        ZStack{
            VStack(alignment: .leading) {
                
                HStack(alignment: .top) {
                    Button(action: {
                        withAnimation{
                            xOffset = -screenWidth * 0.8
                            showProfile.toggle()
                        }
                    }, label: {
                            Image("Profile")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 55, height: 55)
                                .clipShape(Circle())
                    })

                    Spacer()
                }
                Divider()
                VStack(alignment: .listRowSeparatorLeading){

                    ForexCalendarButton(showForexCalendar: $notifications.showForexCalendar)
                    NotificationButton(showNotificationSettings: $showNotificationSettings, xOffset: $xOffset)
                    DeleteButton(showDeleteAlert: $showDeleteAlert)

                }
                .fixedSize()
                Spacer()
            }
            .padding(.horizontal)
            
            .alert(isPresented: $showDeleteAlert){
                Alert(title: Text("Are you sure you want to delete everything?"), primaryButton: .cancel(), secondaryButton: .destructive(Text("Delete")){
                    realmController.deleteAll()
                })
            }
        }
        .frame(
              minWidth: 0,
              maxWidth: .infinity,
              minHeight: 0,
              maxHeight: .infinity,
              alignment: .topLeading
            )
        .background(Color(UIColor.systemBackground))
        .onChange(of: notifications.showForexCalendar) { _ in

        }
        .gesture(
            DragGesture()
                .onChanged({ value in
                    if value.startLocation.x < CGFloat(100.0){
                        if value.translation.width > 0 && xOffset != 0 { // left to right
                            withAnimation {
                                xOffset = currentXOffset + value.translation.width
                            }
                        } else if value.translation.width < 0 && xOffset != -screenWidth * 0.8 {
                            withAnimation {
                                xOffset = currentXOffset + value.translation.width
                            }
                        }
                    }
                })
                .onEnded({ value in
                    if value.translation.width > 0 { // left to right
                        withAnimation {
                            xOffset = 0
                        }
                    } else {
                        withAnimation {
                            xOffset = -screenWidth * 0.8
                        }
                    }
                    currentXOffset = xOffset
                })
        )
    }
    
}

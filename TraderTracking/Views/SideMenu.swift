//
//  SideMenu.swift
//  TraderTracking
//
//  Created by Zach on 9/16/22.
//

import SwiftUI

struct SideMenu: View {
    @EnvironmentObject var realmController: RealmController
    
    var screenWidth = UIScreen.main.bounds.width
    @Binding var showMenu: Bool
    
    @State private var showDeleteAlert: Bool = false
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            VStack(alignment: .leading, spacing: 15) {
                HStack(alignment: .top) {
                    Button(action: {
                        withAnimation{
                            showMenu.toggle()
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
            }
            .padding(.horizontal)
            Button {
                showDeleteAlert.toggle()
                
            } label: {
                Text("Delete")
                    .foregroundColor(.red)
            }
            .alert(isPresented: $showDeleteAlert){
                Alert(title: Text("Are you sure you want to delete everything?"), primaryButton: .cancel(), secondaryButton: .destructive(Text("Delete")){
                    realmController.deleteAll()
                })
            }
            .foregroundColor(.primary)
        }
        .padding(.top)
        .frame(width: getRect().width - 90)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.primary.opacity(0.04).ignoresSafeArea(.container, edges: .vertical))
        .frame(maxHeight: .infinity, alignment: .leading)
//        .gesture(
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
    
}

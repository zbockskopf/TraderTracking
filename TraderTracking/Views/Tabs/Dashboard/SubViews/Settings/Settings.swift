//
//  Settings.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 10/14/22.
//

import SwiftUI
import RealmSwift

struct Settings: View {
    @EnvironmentObject var menuController: MenuController
    @EnvironmentObject var realmController: RealmController
    @State var newAccountBalance: String = ""
    @State var resetAccountAlert: Bool = false
    var body: some View {
        List{
//            DefaultTab()
//                .environmentObject(menuController)
            Section(header: Text("News")){
                NewsScrollToggle(newsDoesScrollToToday: $menuController.newsDoesScrollToToday)
            }
            Section(header: Text("Other")){
                Button {
                    resetAccountAlert.toggle()
                } label: {
                    Text("Reset Account")
                }
                .foregroundColor(.red)
                
                DeleteButton(showDeleteAlert: $menuController.showDeleteAlert)
                    .alert(isPresented: $menuController.showDeleteAlert){
                        Alert(title: Text("Are you sure you want to delete everything?"), primaryButton: .cancel(), secondaryButton: .destructive(Text("Delete")){
                            realmController.deleteAll()
                        })
                    }
                ResetJournalButton(showDeleteAlert: $menuController.showJournalResetAlert)
                    .alert(isPresented: $menuController.showJournalResetAlert){
                        Alert(title: Text("Are you sure you want to reset your Journal"), primaryButton: .cancel(), secondaryButton: .destructive(Text("Reset")){
                            realmController.deleteJournal()
                        })
                    }
                ArchiveButton(showArchiveAlert: $menuController.showArchiveAlert)
                    .alert(isPresented: $menuController.showArchiveAlert){
                        Alert(title: Text("Are you sure you want to archive everything?"), primaryButton: .cancel(), secondaryButton: .destructive(Text("Yes")){
                            realmController.archiveTrades()
                        })
                    }
                RemoveTradesButton(showDeletedTradesAlert: $menuController.showDeletedTradesAlert)
                    .alert(isPresented: $menuController.showDeletedTradesAlert){
                        Alert(title: Text("Are you sure you want to delete everything?"), primaryButton: .cancel(), secondaryButton: .destructive(Text("Yes")){
                            realmController.deleteAllDeletedTrades()
                        })
                    }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Settings")
        .alert("Reset Balance", isPresented: $resetAccountAlert, actions: {
            TextField("New Value", text: $newAccountBalance)
                .keyboardType(.decimalPad)
            
            Button("Reset", role: .destructive ,action: {
                realmController.resetAccount(newVal: newAccountBalance)
            })
                .foregroundColor(.red)
            Button("Cancel", role: .cancel, action:{})
        }, message: {
            Text("add new value")
        })
        .onAppear{
            menuController.showListView = true
        }
        .onDisappear{
            menuController.showListView = false
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}

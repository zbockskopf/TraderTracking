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
        Form{
            DefaultTab()
                .environmentObject(menuController)
            Button {
                resetAccountAlert.toggle()
            } label: {
                Text("Reset Account")
            }
            .foregroundColor(.red)
            DeleteButton(showDeleteAlert: $menuController.showDeleteAlert)

        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Settings")
        .alert(isPresented: $menuController.showDeleteAlert){
            Alert(title: Text("Are you sure you want to delete everything?"), primaryButton: .cancel(), secondaryButton: .destructive(Text("Delete")){
                realmController.deleteAll()
            })
        }
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
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}

//
//  Settings.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 10/14/22.
//

import SwiftUI

struct Settings: View {
    @EnvironmentObject var menuController: MenuController
    @EnvironmentObject var realmController: RealmController
    var body: some View {
        List{
            DeleteButton(showDeleteAlert: $menuController.showDeleteAlert)
            DefaultTab()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Settings")
        .alert(isPresented: $menuController.showDeleteAlert){
            Alert(title: Text("Are you sure you want to delete everything?"), primaryButton: .cancel(), secondaryButton: .destructive(Text("Delete")){
                realmController.deleteAll()
            })
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}

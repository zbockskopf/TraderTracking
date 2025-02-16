//
//  ModelsView.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 4/21/23.
//

import SwiftUI
import RealmSwift

struct ModelsListView: View {
    @EnvironmentObject var menuController: MenuController
    @State private var showAddModel = false
    @ObservedObject private var viewModel: ModelsListViewModel
    
    init(realm: Realm) {
        viewModel = ModelsListViewModel(realm: realm)
    }
    
    var body: some View {
//        NavigationView {
            List {
                ForEach(viewModel.models) { model in
                    NavigationLink(destination: EditModelView(realm: viewModel.models.realm!, model: model)) {
                        Text(model.name)
                    }
                    .contextMenu {
                        Button(action: {
                            deleteModel(model: model)
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationBarTitle("Models", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                showAddModel.toggle()
            }, label: {
                Image(systemName: "plus")
            }))
            .sheet(isPresented: $showAddModel) {
                AddModelView(realm: viewModel.models.realm!)
            }
            .onAppear{
                menuController.showListView = true
            }
            .onDisappear{
                menuController.showListView = false
            }
//        }
    }
    
    private func deleteModel(model: Model) {
        guard let realm = viewModel.models.realm else { return }
        do {
            try realm.write {
                realm.delete(model)
            }
        } catch {
            print("Error deleting model: \(error)")
        }
    }
}


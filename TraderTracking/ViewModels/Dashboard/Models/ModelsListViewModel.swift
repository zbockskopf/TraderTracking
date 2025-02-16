//
//  ModelsListViewModel.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 4/21/23.
//

import RealmSwift
import SwiftUI

class ModelsListViewModel: ObservableObject {
    @Published var models: Results<Model>
    private var notificationToken: NotificationToken?
    
    init(realm: Realm) {
        models = realm.objects(Model.self)
        notificationToken = models.observe { [weak self] _ in
            self?.objectWillChange.send()
        }
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    func deleteModel(at indexSet: IndexSet) {
        guard let realm = models.realm else { return }
        indexSet.forEach { index in
            let model = models[index]
            do {
                try realm.write {
                    realm.delete(model)
                }
            } catch {
                print("Error deleting model: \(error)")
            }
        }
    }
}

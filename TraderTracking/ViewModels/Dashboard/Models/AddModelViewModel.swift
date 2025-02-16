//
//  AddModelViewModel.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 4/21/23.
//

import SwiftUI
import RealmSwift

// ViewModel
class AddModelViewModel: ObservableObject {
    private var realm: Realm
    
    init(realm: Realm) {
        self.realm = realm
    }
    
    func addModel(name: String, photos: [UIImage], rules: String?) {
        let model = Model(name: name, rules: (rules ?? ""))

        photos.forEach { photo in
            if let photoData = photo.jpegData(compressionQuality: 0.7) {
                model.photos.append(photoData)
            }
        }

        do {
            try realm.write {
                realm.add(model)
            }
        } catch {
            print("Error adding model: \(error)")
        }
    }
}

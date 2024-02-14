//
//  DailyReviewViewModel.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 6/29/23.
//

import RealmSwift
import SwiftUI

class DailyReviewViewModel: ObservableObject {
    @Published var reviews: Results<DailyReview>
    private var notificationToken: NotificationToken?
    
    init(realm: Realm) {
        reviews = realm.objects(DailyReview.self)
        notificationToken = reviews.observe { [weak self] _ in
            self?.objectWillChange.send()
        }
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
//    func deleteModel(at indexSet: IndexSet) {
//        guard let realm = models.realm else { return }
//        indexSet.forEach { index in
//            let model = models[index]
//            do {
//                try realm.write {
//                    realm.delete(model)
//                }
//            } catch {
//                print("Error deleting model: \(error)")
//            }
//        }
//    }
}

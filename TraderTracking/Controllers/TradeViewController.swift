//
//  TradeViewController.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 4/4/23.
//

import Foundation
import SwiftUI
import RealmSwift

class TradeViewConroller: ObservableObject {
    let realm: Realm = RealmController.shared.realm
    let account: Account = RealmController.shared.account
}

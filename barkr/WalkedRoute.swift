//
//  WalkedRoute.swift
//  barkr
//
//  Created by Tan Yücel on 13.06.19.
//  Copyright © 2019 luk. All rights reserved.
//

import Foundation
import RealmSwift

class WalkedRoute: Object {
    @objc dynamic var routeId: Int = 0
    @objc dynamic var timestamp: Double = 0
    @objc dynamic var duration: Double = 0
    @objc dynamic var distance: Double = 0
    @objc dynamic var dogbags: Int = 0
}

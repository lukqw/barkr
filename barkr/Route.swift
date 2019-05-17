//
//  Route.swift
//  barkr
//
//  Created by luk on 5/14/19.
//  Copyright © 2019 luk. All rights reserved.
//

import UIKit
import MapKit
class Route: NSObject {

    let time: Int
    let dogBagCount: Int
    let distance: Int
    var routes: [MKRoute] = []
    var dogBags: [DogBag] = []

    init(time: Int, dogBagCount: Int, distance: Int) {
        self.time = time
        self.dogBagCount = dogBagCount
        self.distance = distance
        super.init()
    }

}

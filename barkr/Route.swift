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

    let id: Int
    let time: Int
    let dogBagCount: Int
    let distance: Int
    var routes: [MKRoute] = []
    var dogBags: [DogBag] = []
    var favorite: Bool

    init(time: Int, dogBagCount: Int, distance: Int) {
        self.id = -1
        self.time = time
        self.dogBagCount = dogBagCount
        self.distance = distance
        self.favorite = false
        super.init()
    }

    init(id: Int, time: Int, dogBagCount: Int, distance: Int, favorite: Bool) {
        self.id = id
        self.time = time
        self.dogBagCount = dogBagCount
        self.distance = distance
        self.favorite = favorite
        super.init()
    }
    
    init(id: Int, time: Int, dogBagCount: Int, distance: Int, favorite: Bool, dogBags: [DogBag]) {
        self.id = id
        self.time = time
        self.dogBagCount = dogBagCount
        self.distance = distance
        self.favorite = favorite
        self.dogBags = dogBags
        super.init()
    }

}

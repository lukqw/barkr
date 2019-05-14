//
//  Route.swift
//  barkr
//
//  Created by luk on 5/14/19.
//  Copyright © 2019 luk. All rights reserved.
//

import UIKit

class Route: NSObject {

    let time: Int
    let dogBags: Int
    let distance: Int

    init(time: Int, dogBags: Int, distance: Int) {
        self.time = time
        self.dogBags = dogBags
        self.distance = distance
        super.init()
    }

}

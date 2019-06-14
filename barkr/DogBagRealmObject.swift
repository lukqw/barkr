//
//  DogBagRealmObject.swift
//  barkr
//
//  Created by Tan Yücel on 13.06.19.
//  Copyright © 2019 luk. All rights reserved.
//

import Foundation
import RealmSwift
import MapKit

class DogBagRealmObject: Object {
    @objc dynamic var latitude = 0.0
    @objc dynamic var longitude = 0.0
    
    var dogbag: DogBag {
        return DogBag.init(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
    }
    
}

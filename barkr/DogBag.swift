//
//  DogBag.swift
//  barkr
//
//  Created by luk on 5/14/19.
//  Copyright © 2019 luk. All rights reserved.
//

import MapKit

class DogBag: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let markerTintColor: UIColor = .init(red: 0.17, green: 0.55, blue: 0.22, alpha: 1.0)
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }

}

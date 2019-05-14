//
//  DogBagViews.swift
//  barkr
//
//  Created by luk on 5/14/19.
//  Copyright © 2019 luk. All rights reserved.
//

import UIKit
import MapKit

class DogBagMarkerView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let dogbag = newValue as? DogBag else { return }
            markerTintColor = dogbag.markerTintColor
        }
    }
}

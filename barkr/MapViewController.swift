//
//  MapViewController.swift
//  barkr
//
//  Created by luk on 5/10/19.
//  Copyright © 2019 luk. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    var dogBagArray: [DogBag] = [DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.167471, longitude: 16.278580)),
                                 DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.168632, longitude: 16.275215)),
                                 DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.170082, longitude: 16.277615)),
                                 DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.168849, longitude: 16.279870)),
                                 DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.170932, longitude: 16.282821)),
                                 DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.164921, longitude: 16.281158)),
                                 DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.167983, longitude: 16.285675)),
                                 DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.165894, longitude: 16.284109)),
                                 DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.166939, longitude: 16.280633)),
                                 DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.171461, longitude: 16.279237)),
                                 DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.171991, longitude: 16.286984))]

    @IBOutlet weak var mapViewOutlet: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        mapViewOutlet.register(DogBagView.self,
                                   forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        self.mapViewOutlet.showAnnotations(dogBagArray, animated: true)
        mapViewOutlet.userTrackingMode = .follow
    }

}

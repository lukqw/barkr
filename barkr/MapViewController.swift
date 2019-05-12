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
    let regionRadius: CLLocationDistance = 1000

    @IBOutlet weak var mapViewOutlet: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        mapViewOutlet.userTrackingMode = .follow
        /*if let userLocation = mapViewOutlet.userLocation.location?.coordinate {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: userLocation, span: span)
            mapViewOutlet.setRegion(region, animated: true)
        }*/
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

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
    
    var dogBagArray = [DogBag]()

    @IBOutlet weak var mapViewOutlet: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        mapViewOutlet.register(DogBagView.self,
                               forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        let session = URLSession.shared
        let url = URL(string: "https://data.wien.gv.at/daten/geo?service=WFS&request=GetFeature&version=1.1.0&typeName=ogdwien:HUNDESACKERLOGD&srsName=EPSG:4326&outputFormat=json")!
        let task = session.dataTask(with: url, completionHandler: {data, response, error in
            if error != nil {
                //error
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                //error
                return
            }
            guard let mime = response?.mimeType, mime == "application/json" else {
                //error
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data!) as? [String: Any] {
                    let features = json["features"] as? [[String: Any]]
                    for feature in features! {
                        if let geometry = feature["geometry"] as? [String: Any] {
                            if let coordinates = geometry["coordinates"] as? [Double] {
                                let poiLocation = CLLocationCoordinate2D(latitude: coordinates[1], longitude: coordinates[0])
                                let sourceLocation = self.mapViewOutlet.userLocation.location?.coordinate
                                let difference = abs(sourceLocation!.latitude - poiLocation.latitude) +
                                    abs(sourceLocation!.longitude - poiLocation.longitude)
                                if difference < 0.02 {
                                    let dogbag = DogBag(coordinate: poiLocation)
                                    self.dogBagArray.append(dogbag)
                                }
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.mapViewOutlet.showAnnotations(self.dogBagArray, animated: false)
                    self.mapViewOutlet.userTrackingMode = .follow
                }
            } catch {
                //error
            }
        })
        task.resume()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueRouteSelection" {
            // swiftlint:disable force_cast
            let nextScreen = segue.destination as! RouteSelectionViewController
            nextScreen.dogBagArray = dogBagArray
        } 
        // swiftlint:enable force_cast
    }
}

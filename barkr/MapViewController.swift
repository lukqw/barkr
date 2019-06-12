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

    @IBOutlet weak var mapViewOutlet: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        var dogBagArray = [DogBag]()
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
                                let dogbag = DogBag(coordinate: CLLocationCoordinate2D(latitude: coordinates[1], longitude: coordinates[0]))
                                dogBagArray.append(dogbag)
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.mapViewOutlet.showAnnotations(dogBagArray, animated: false)
                    self.mapViewOutlet.userTrackingMode = .follow
                }
            } catch {
                //error
            }
        })
        task.resume()
    }
}

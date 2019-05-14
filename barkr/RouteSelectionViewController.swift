//
//  RouteSelectionViewController.swift
//  barkr
//
//  Created by luk on 5/13/19.
//  Copyright © 2019 luk. All rights reserved.
//

import UIKit
import MapKit

class RouteSelectionViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate {

    var routeArray: [Route] = [Route(time: 30, dogBags: 5, distance: 5300),
                             Route(time: 27, dogBags: 4, distance: 5025),
                             Route(time: 33, dogBags: 3, distance: 5740),
                             Route(time: 34, dogBags: 3, distance: 5800),
                             Route(time: 23, dogBags: 1, distance: 4700),
                             Route(time: 26, dogBags: 0, distance: 4900)]
    var dogBagArray: [DogBag] = [DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.167471, longitude: 16.278580)),
                                 DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.168632, longitude: 16.275215)),
                                 DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.170082, longitude: 16.277615)),
                                 DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.168849, longitude: 16.279870))]

    @IBOutlet var routeSelectionTableView: UITableView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routeArray.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = routeSelectionTableView.dequeueReusableCell(withIdentifier: "routeSelectionCell", for: indexPath)
        // swiftlint:disable force_cast
        as! RouteSelectionCell
        // swiftlint:enable force_cast

        let route = routeArray[indexPath.row]
        cell.timeLabel?.text = String(route.time) + "min"
        cell.bagFlagLabel?.text = String(route.dogBags)
        cell.distanceLabel?.text = String(route.distance) + "m"

        return cell
    }

    @IBOutlet var routeSelectionMap: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()

        routeSelectionMap.delegate = self

        let sourceLocation = routeSelectionMap.userLocation.location?.coordinate

        routeSelectionMap.register(DogBagMarkerView.self,
                                   forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)

        self.routeSelectionMap.showAnnotations(dogBagArray, animated: true)

        if sourceLocation != nil {
            drawFromAtoB(sourceLocation.unsafelyUnwrapped, end: dogBagArray[0].coordinate)

            let dogBagArrayLength = dogBagArray.count-1
            for index in 0...dogBagArrayLength-1 {
                drawFromAtoB(dogBagArray[index].coordinate, end: dogBagArray[index+1].coordinate)
            }
            drawFromAtoB(dogBagArray[dogBagArrayLength].coordinate, end: sourceLocation.unsafelyUnwrapped)

        }
        routeSelectionMap.userTrackingMode = .follow
    }

    func drawFromAtoB(_ start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) {
        let sourcePlacemark = MKPlacemark(coordinate: start)
        let destinationPlacemark = MKPlacemark(coordinate: end)

        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.requestsAlternateRoutes = false
        directionRequest.transportType = .walking

        let directions = MKDirections(request: directionRequest)
        
        directions.calculate { (response, error) in
            guard let response = response else {
                if let error = error {
                    print(error)
                }
                return
            }
            let route = response.routes[0]
            self.routeSelectionMap.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = self.view.tintColor
        renderer.lineWidth = 4.0
        return renderer
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("section \(indexPath.section)")
        print("row \(indexPath.row)")
    }

}

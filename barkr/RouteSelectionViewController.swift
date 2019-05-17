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

    var routeArray: [Route] = [Route(time: 30, dogBagCount: 4, distance: 5300),
                             Route(time: 27, dogBagCount: 4, distance: 5025),
                             Route(time: 33, dogBagCount: 4, distance: 5740),
                             Route(time: 34, dogBagCount: 3, distance: 5800),
                             Route(time: 23, dogBagCount: 4, distance: 4700),
                             Route(time: 26, dogBagCount: 2, distance: 4900)]
    var dogBagArray: [[DogBag]] = [[DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.167471, longitude: 16.278580)),
                                    DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.168632, longitude: 16.275215)),
                                    DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.170082, longitude: 16.277615)),
                                    DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.168849, longitude: 16.279870))],
                                   [DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.166939, longitude: 16.280633)),
                                    DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.164921, longitude: 16.281158)),
                                    DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.165894, longitude: 16.284109)),
                                    DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.167983, longitude: 16.285675))],
                                   [DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.170932, longitude: 16.282821)),
                                    DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.171461, longitude: 16.279237)),
                                    DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.170082, longitude: 16.277615)),
                                    DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.168849, longitude: 16.279870))],
                                   [DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.168849, longitude: 16.279870)),
                                    DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.167471, longitude: 16.278580)),
                                    DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.166939, longitude: 16.280633))],
                                   [DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.166939, longitude: 16.280633)),
                                    DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.167471, longitude: 16.278580)),
                                    DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.168849, longitude: 16.279870)),
                                    DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.170932, longitude: 16.282821))],
                                   [DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.167983, longitude: 16.285675)),
                                    DogBag(coordinate: CLLocationCoordinate2D(latitude: 48.170932, longitude: 16.282821))]]

    var durationValue: Int = 30
    var kmValue: Int = 5
    private var fetchNotificaitonPicker: NSObjectProtocol?

    @IBOutlet var minKmSegmentedControl: UISegmentedControl!
    @IBOutlet var pickerValueField: UIButton!

    @IBOutlet var routeSelectionTableView: UITableView!
    @IBOutlet var routeSelectionMap: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchNotificaitonPicker = NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: "valuePicker"), object: nil, queue: .main) { (notification) in
            // swiftlint:disable force_cast
            let pickerVC = notification.object as! PickerViewController
            // swiftlint:enable force_cast
            if pickerVC.isKm {
                self.kmValue = pickerVC.value
                self.pickerValueField.setTitle(String(pickerVC.value) + " Km", for: .normal)
            } else {
                self.durationValue = pickerVC.value
                self.pickerValueField.setTitle(String(pickerVC.value) + " Min", for: .normal)
            }
        }
        routeSelectionMap.delegate = self
        routeSelectionMap.register(DogBagView.self,
                                   forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        self.routeSelectionMap.showAnnotations(dogBagArray[0], animated: true)
        drawRouteForDogBags(dogBagArray[0], 0)
        routeSelectionTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
        routeSelectionMap.userTrackingMode = .follow
    }

    @IBAction func minKmSegmentedControlPressed(_ sender: Any) {
        if minKmSegmentedControl.selectedSegmentIndex == 0 {
            self.pickerValueField.setTitle(String(durationValue) + " Min", for: .normal)
        } else {
            self.pickerValueField.setTitle(String(kmValue) + " Km", for: .normal)
        }
    }

    @IBAction func dismissVC(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueOpenPicker" {
            // swiftlint:disable force_cast
            let popup = segue.destination as! PickerViewController
            if minKmSegmentedControl.selectedSegmentIndex == 0 {
                popup.isKm = false
                popup.value = durationValue
            } else {
                popup.isKm = true
                popup.value = kmValue
            }
        } else if segue.identifier == "currentRouteViewSegue" {
            let nextView = segue.destination as! CurrentRouteViewController
            let num: Int = routeSelectionTableView.indexPathForSelectedRow!.row
            nextView.selectedRoute = routeArray[num]
        }
        // swiftlint:enable force_cast
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routeArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = routeSelectionTableView.dequeueReusableCell(withIdentifier: "routeSelectionCell", for: indexPath)
            // swiftlint:disable force_cast
            as! RouteSelectionCell
            // swiftlint:enable force_cast

        let route = routeArray[indexPath.row]
        cell.timeLabel?.text = String(route.time) + " min"
        cell.bagFlagLabel?.text = String(route.dogBagCount)
        cell.distanceLabel?.text = String(route.distance/1000) + ","
                                    + String(route.distance%1000/100)
                                    + String(route.distance%100/10) + " km"
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 0.17, green: 0.55, blue: 0.22, alpha: 0.20)
        cell.selectedBackgroundView = backgroundView
        return cell
    }

    func drawRouteForDogBags(_ route: [DogBag], _ selectedRow: Int) {
        let sourceLocation = routeSelectionMap.userLocation.location?.coordinate
        if sourceLocation != nil {
            routeArray[selectedRow].dogBags = route
            drawFromAtoB(sourceLocation.unsafelyUnwrapped, end: route[0].coordinate, selectedRow)
            let routeLength = route.count-1
            for index in 0...routeLength-1 {
                drawFromAtoB(route[index].coordinate, end: route[index+1].coordinate, selectedRow)
            }
            drawFromAtoB(route[routeLength].coordinate, end: sourceLocation.unsafelyUnwrapped, selectedRow)
        }
    }

    func drawFromAtoB(_ start: CLLocationCoordinate2D, end: CLLocationCoordinate2D, _ selectedRow: Int) {
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
            self.routeArray[selectedRow].routes.append(route)
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
        self.routeSelectionMap.annotations.forEach {
            if !($0 is MKUserLocation) {
                self.routeSelectionMap.removeAnnotation($0)
            }
        }
        let allRoutes = self.routeSelectionMap.overlays
        self.routeSelectionMap.removeOverlays(allRoutes)
        self.routeSelectionMap.showAnnotations(self.dogBagArray[indexPath.row], animated: true)
        drawRouteForDogBags(self.dogBagArray[indexPath.row], indexPath.row)
        let span = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
        let sourceLocation = routeSelectionMap.userLocation.location?.coordinate
        let mapRegion = MKCoordinateRegion(center: sourceLocation.unsafelyUnwrapped, span: span)
        routeSelectionMap.setRegion(mapRegion, animated: true)
    }

    deinit {
        NotificationCenter.default.removeObserver(fetchNotificaitonPicker as Any)
    }
}

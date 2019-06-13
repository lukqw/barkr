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

    var dogBagArray: [DogBag] = []
    var routeArray: [Route] = []
    var routeOverviewOnly = false
    var durationValue: Int = 30
    var kmValue: Int = 5
    private var fetchNotificaitonPicker: NSObjectProtocol?

    @IBOutlet var minKmSegmentedControl: UISegmentedControl!
    @IBOutlet var pickerValueField: UIButton!

    @IBOutlet weak var segmentToolbar: UIToolbar!
    @IBOutlet var routeSelectionTableView: UITableView!
    @IBOutlet var routeSelectionMap: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        generateRoutes()
        if routeOverviewOnly {
            viewWillDisappear(false)
            segmentToolbar.removeFromSuperview()
            for const in view.constraints {
                if const.identifier == "maptop" {
                    const.constant = 0
                }
            }
        }
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
        if(routeArray.count > 0) {
            self.routeSelectionMap.showAnnotations(routeArray[0].dogBags, animated: true)
            drawRouteForDogBags(routeArray[0].dogBags, 0)
            routeSelectionTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
        }
        routeSelectionMap.userTrackingMode = .follow
    }
    func getNearestPOIs(location: CLLocationCoordinate2D) -> [DogBag] {
        var resultPOIs = [DogBag]()
        var diffArray = [Double]()
        for poi in dogBagArray {
            let difference = abs(location.latitude - poi.coordinate.latitude) +
                abs(location.longitude - poi.coordinate.longitude)
            diffArray.append(difference)
        }
        for _ in 1...5 {
            let index = diffArray.firstIndex(of: diffArray.min()!)
            diffArray[index!] = 10000
            resultPOIs.append(dogBagArray[index!])
        }
        return resultPOIs
    }
    func generateRoutes() {
        let nearestPoints = getNearestPOIs(location: routeSelectionMap.userLocation.location!.coordinate)
        for point in nearestPoints {
            print(point.coordinate.latitude)
            print(point.coordinate.longitude)
        }
        routeArray.append(Route(id: -1, time: 1, dogBagCount: 4, distance: 5, favorite: true, dogBags: nearestPoints))
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
        self.routeSelectionMap.showAnnotations(self.routeArray[indexPath.row].dogBags, animated: true)
        drawRouteForDogBags(self.routeArray[indexPath.row].dogBags, indexPath.row)
        let span = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
        let sourceLocation = routeSelectionMap.userLocation.location?.coordinate
        let mapRegion = MKCoordinateRegion(center: sourceLocation.unsafelyUnwrapped, span: span)
        routeSelectionMap.setRegion(mapRegion, animated: true)
    }

    deinit {
        NotificationCenter.default.removeObserver(fetchNotificaitonPicker as Any)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

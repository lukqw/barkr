//
//  RouteSelectionViewController.swift
//  barkr
//
//  Created by luk on 5/13/19.
//  Copyright © 2019 luk. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift
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
        if routeOverviewOnly {
            viewWillDisappear(false)
            segmentToolbar.removeFromSuperview()
            for const in view.constraints {
                if const.identifier == "maptop" {
                    const.constant = 0
                }
            }
        } else {
            generateRoutes()
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
        if routeArray.count > 0 {
            self.routeSelectionMap.showAnnotations(routeArray[0].getDogbagArray(), animated: true)
            drawRouteForDogBags(routeArray[0].getDogbagArray(), 0)
            routeSelectionTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
        }
        routeSelectionMap.userTrackingMode = .follow
    }
    func getNearestPOIs(location: CLLocationCoordinate2D, dogBags: [DogBag]) -> [DogBag] {
        var resultPOIs = [DogBag]()
        var diffArray = [Double]()
        for poi in dogBags {
            let difference = abs(location.latitude - poi.coordinate.latitude) +
                abs(location.longitude - poi.coordinate.longitude)
            diffArray.append(difference)
        }
        for _ in 1...5 {
            let index = diffArray.firstIndex(of: diffArray.min()!)
            diffArray[index!] = 10000
            resultPOIs.append(dogBags[index!])
        }
        return resultPOIs
    }
    func getNearestPOI(location: CLLocationCoordinate2D, dogBags: [DogBag]) -> DogBag {
        var diffArray = [Double]()
        for poi in dogBags {
            let difference = abs(location.latitude - poi.coordinate.latitude) +
                abs(location.longitude - poi.coordinate.longitude)
            diffArray.append(difference)
        }
        return dogBags[diffArray.firstIndex(of: diffArray.min()!)!]
    }
    func generateRoutes() {
        let isKm = minKmSegmentedControl.selectedSegmentIndex != 0
        let firstLoc = routeSelectionMap.userLocation.location!.coordinate
        var pointA = routeSelectionMap.userLocation.location!.coordinate
        var pointB = DogBag(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))
        let wantedValue = isKm ? kmValue*1000 : durationValue
        for _ in 1...5 {
            var total = 0.0
            let route = Route.init(0, 0, 0, 0, false)
            var dogBags = dogBagArray
            while total < Double(wantedValue)/2 {
                let closestPoints = getNearestPOIs(location: pointA, dogBags: dogBags)
                pointB = closestPoints.randomElement()!
                let index = dogBags.firstIndex(of: pointB)!
                dogBags.remove(at: index)

                let difference = sqrt(pow(pointA.latitude - pointB.coordinate.latitude, 2) +
                    pow(pointA.longitude - pointB.coordinate.longitude, 2))
                let time = Int(difference * 1000)
                let distance = difference * 100000
                var dogbagarr = route.getDogbagArray()
                dogbagarr.append(pointB)
                route.setDogbagArray(dogbagarr)
                route.distance += distance
                route.time += time
                route.dogBagCount += 1
                total += isKm ? distance : Double(time)

                pointA = pointB.coordinate
            }
            var stop = false
            while !stop && dogBags.count > 5 && route.dogBagCount < 10 {
                let closestPoints = getNearestPOIs(location: pointA, dogBags: dogBags)
                let startClosestPoint = getNearestPOI(location: firstLoc, dogBags: closestPoints)
                let startClosestDiff = sqrt(pow(firstLoc.latitude - startClosestPoint.coordinate.latitude, 2) +
                    pow(firstLoc.longitude - startClosestPoint.coordinate.longitude, 2))
                let currDiff = sqrt(pow(firstLoc.latitude - pointA.latitude, 2) +
                    pow(firstLoc.longitude - pointA.longitude, 2))
                if currDiff <= startClosestDiff {
                    stop = true
                    let time = Int(currDiff * 1000)
                    let distance = currDiff * 100000
                    route.distance += distance
                    route.time += time
                    total += isKm ? distance : Double(time)
                    break
                }
                if !stop {
                    pointB = startClosestPoint
                    let index = dogBags.firstIndex(of: pointB)!
                    dogBags.remove(at: index)

                    let difference = sqrt(pow(pointA.latitude - pointB.coordinate.latitude, 2) +
                        pow(pointA.longitude - pointB.coordinate.longitude, 2))
                    let time = Int(difference * 1000)
                    let distance = difference * 100000
                    var dogbagarr = route.getDogbagArray()
                    dogbagarr.append(pointB)
                    route.setDogbagArray(dogbagarr)
                    route.distance += distance
                    route.time += time
                    route.dogBagCount += 1
                    total += isKm ? distance : Double(time)
                    pointA = pointB.coordinate
                }
            }
            if route.distance > 0 {
                routeArray.append(route)
            }
        }
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
        cell.distanceLabel?.text = route.distanceToString()
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 0.17, green: 0.55, blue: 0.22, alpha: 0.20)
        cell.selectedBackgroundView = backgroundView
        return cell
    }

    func drawRouteForDogBags(_ route: [DogBag], _ selectedRow: Int) {
        let sourceLocation = routeSelectionMap.userLocation.location?.coordinate
        if sourceLocation != nil {
            // swiftlint:disable force_try
            let realm = try! Realm()
            try! realm.write {
                routeArray[selectedRow].setDogbagArray(route)
            }
            // swiftlint:enable force_try
            drawFromAtoB(sourceLocation.unsafelyUnwrapped, end: route[0].coordinate, selectedRow)
            let routeLength = route.count-1
            for index in 0...routeLength-1 {
                drawFromAtoB(route[index].coordinate, end: route[index+1].coordinate, selectedRow)
            }
            drawFromAtoB(route[routeLength].coordinate, end: sourceLocation.unsafelyUnwrapped, selectedRow)
        }
    }

    func drawFromAtoB(_ start: CLLocationCoordinate2D, end: CLLocationCoordinate2D, _ selectedRow: Int) {
        print(start)
        print(end)
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
        self.routeSelectionMap.showAnnotations(self.routeArray[indexPath.row].getDogbagArray(), animated: true)
        drawRouteForDogBags(self.routeArray[indexPath.row].getDogbagArray(), indexPath.row)
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

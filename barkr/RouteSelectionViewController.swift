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

    var routeArray: [Route] = [Route(time: 30, dogBags: 4, distance: 5300),
                             Route(time: 27, dogBags: 4, distance: 5025),
                             Route(time: 33, dogBags: 4, distance: 5740),
                             Route(time: 34, dogBags: 3, distance: 5800),
                             Route(time: 23, dogBags: 4, distance: 4700),
                             Route(time: 26, dogBags: 2, distance: 4900)]
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

    var minutesValue: Int = 30
    var kmValue: Int = 3
    @IBOutlet weak var minOrKmButton: UIButton!
    @IBOutlet weak var tabBar: UISegmentedControl!
    @IBOutlet weak var minOrKmPicker: UIPickerView!
    @IBOutlet weak var pickerContainerView: UIView!
    @IBOutlet weak var pickerContainerDone: UIButton!
    @IBOutlet weak var pickerContainerCancel: UIButton!
    var unit: String = " min"
    @IBOutlet weak var pickerContainerToolbar: UIToolbar!

    @IBOutlet var routeSelectionTableView: UITableView!
    @IBOutlet var routeSelectionMap: MKMapView!
    @IBAction func tabBarSelectionChanged(_ sender: Any) {
        updateMinOrKmButton()
        minOrKmPicker.reloadAllComponents()
    }
    func updateMinOrKmButton() {
        switch tabBar.selectedSegmentIndex {
        case 0:
            unit = " min"
            minOrKmButton.setTitle(minutesValue.description + unit, for: .normal)
        case 1:
            unit = " km"
            minOrKmButton.setTitle(kmValue.description + unit, for: .normal)
        default:
            print("default switch case shouldn't have happened")
        }
    }
    @IBAction func showPicker(_ sender: Any) {
        if tabBar.selectedSegmentIndex == 0 {
            minOrKmPicker.selectRow(minutesValue - 1, inComponent: 0, animated: false)
        } else {
            minOrKmPicker.selectRow(kmValue - 1, inComponent: 0, animated: false)
        }
        pickerContainerView.isHidden = false
    }

    func initializePicker() {
        self.view.bringSubviewToFront(pickerContainerView)
        minOrKmPicker.delegate = self
        minOrKmPicker.dataSource = self
        //pickerContainerView.layer.cornerRadius = 10
        pickerContainerView.layer.borderWidth = 0.5
        pickerContainerView.layer.borderColor = UIColor.init(white: 0.8, alpha: 1).cgColor
        minOrKmPicker.showsSelectionIndicator = true
        pickerContainerView.isHidden = true
        /*pickerContainerToolbar.subviews.forEach { view in
            view.backgroundColor = UIColor.groupTableViewBackground
            view.layer.borderWidth = 0
        }
        pickerContainerToolbar.layer.cornerRadius = 10
        pickerContainerToolbar.layer.borderWidth = 0
        pickerContainerToolbar.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        */
        pickerContainerToolbar.subviews.forEach { view in
            view.backgroundColor = UIColor.groupTableViewBackground
            view.layer.borderWidth = 0
        }
    }
    @IBAction func dismissVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func pickerValueCancelled(_ sender: Any) {
        pickerContainerView.isHidden = true
    }
    @IBAction func pickerValueSelected(_ sender: Any) {
        if tabBar.selectedSegmentIndex == 0 {
            minutesValue = minOrKmPicker.selectedRow(inComponent: 0) + 1
        } else {
            kmValue = minOrKmPicker.selectedRow(inComponent: 0) + 1
        }
        pickerContainerView.isHidden = true
        updateMinOrKmButton()
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
        cell.bagFlagLabel?.text = String(route.dogBags)
        cell.distanceLabel?.text = String(route.distance/1000) + ","
                                    + String(route.distance%1000/100)
                                    + String(route.distance%100/10) + " km"
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 0.17, green: 0.55, blue: 0.22, alpha: 0.15)
        cell.selectedBackgroundView = backgroundView
        return cell
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initializePicker()
        routeSelectionMap.delegate = self
        routeSelectionMap.register(DogBagView.self,
                                   forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)

        self.routeSelectionMap.showAnnotations(dogBagArray[0], animated: true)
        drawRouteForDogBags(dogBagArray[0])
        routeSelectionTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
        routeSelectionMap.userTrackingMode = .follow
    }

    func drawRouteForDogBags(_ route: [DogBag]) {
        let sourceLocation = routeSelectionMap.userLocation.location?.coordinate
        if sourceLocation != nil {
            drawFromAtoB(sourceLocation.unsafelyUnwrapped, end: route[0].coordinate)
            let routeLength = route.count-1
            for index in 0...routeLength-1 {
                drawFromAtoB(route[index].coordinate, end: route[index+1].coordinate)
            }
            drawFromAtoB(route[routeLength].coordinate, end: sourceLocation.unsafelyUnwrapped)
        }
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
        let allAnnotations = self.routeSelectionMap.annotations
        self.routeSelectionMap.removeAnnotations(allAnnotations)
        let allRoutes = self.routeSelectionMap.overlays
        self.routeSelectionMap.removeOverlays(allRoutes)
        drawRouteForDogBags(self.dogBagArray[indexPath.row])
        self.routeSelectionMap.showAnnotations(self.dogBagArray[indexPath.row], animated: true)
        routeSelectionMap.userTrackingMode = .follow
    }

}

extension RouteSelectionViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch tabBar.selectedSegmentIndex {
        case 0:
            return 180
        case 1:
            return 10
        default:
            print("default case shouldnt have happened")
            return 100
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (row + 1).description
    }
}

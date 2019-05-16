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
        initializePicker()
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

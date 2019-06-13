//
//  CurrentRouteViewController.swift
//  barkr
//
//  Created by Tan Yücel on 16.05.19.
//  Copyright © 2019 luk. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class CurrentRouteViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    weak var timer: Timer?
    var startTime: Double = 0
    var time: Double = 0
    var elapsed: Double = 0
    var startLocation: CLLocation?
    var lastLocation: CLLocation?
    var traveledDistance: Double = 0
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var blurredContainer: UIVisualEffectView!
    @IBOutlet weak var stopButton: UIButton!
    private var fetchNotificaitonSummary: NSObjectProtocol?
    @IBOutlet weak var centerLocationButton: UIButton!
    @IBOutlet weak var centerLocationButtonContainer: UIVisualEffectView!
    var selectedRoute: Route?
    var visitedDogbags: Int = 0
    var locationManager = CLLocationManager()

    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var labelSecond: UILabel!
    @IBOutlet weak var labelMinute: UILabel!
    @IBOutlet weak var pooIcon: UIImageView!
    @IBOutlet weak var dogBagProgressLabel: UILabel!
    @IBAction func centerLocation(_ sender: Any) {
        mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        start()
        fetchNotificaitonSummary = NotificationCenter.default.addObserver(
        forName: NSNotification.Name(rawValue: "summaryDone"), object: nil, queue: .main) { (_) in
                self.navigationController?.popToRootViewController(animated: true)
        }
        prettify()
        mapView.delegate = self
        for route in selectedRoute!.routes {
            self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
        }
        mapView.register(DogBagView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.showAnnotations(selectedRoute!.getDogbagArray(), animated: true)
        mapView?.userTrackingMode = .follow
        let span = MKCoordinateSpan(latitudeDelta: 0.0008, longitudeDelta: 0.0008)
        let sourceLocation = mapView.userLocation.location?.coordinate
        let mapRegion = MKCoordinateRegion(center: sourceLocation.unsafelyUnwrapped, span: span)
        mapView.setRegion(mapRegion, animated: true)
        mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
        for clregion in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: clregion)
        }
        for dogbag in selectedRoute!.getDogbagArray() {
            let clr = CLCircularRegion(center: dogbag.coordinate,
                                       radius: CLLocationDistance(1),
                                       identifier: dogbag.coordinate.latitude.description +
                                        dogbag.coordinate.longitude.description)
            //print("monitoring region:" + clr.description)
            clr.notifyOnEntry = true
            clr.notifyOnExit = true
            locationManager.startMonitoring(for: clr)
        }
        selectedRoute?.calculateLength()
        //lm.startMonitoringSignificantLocationChanges()

    }
    func start() {
        startTime = Date().timeIntervalSinceReferenceDate - elapsed
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self,
                                     selector: #selector(updateCounter), userInfo: nil, repeats: true)
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        startLocation = locationManager.location
        let loc = CLCircularRegion(center: locationManager.location!.coordinate,
                                   radius: CLLocationDistance(1), identifier: "start")
        loc.notifyOnEntry = true
        locationManager.startMonitoring(for: loc)
    }
    @IBAction func stopButtonPressed(_ sender: Any) {
        elapsed = Date().timeIntervalSinceReferenceDate - startTime
        timer?.invalidate()
        for clregion in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: clregion)
        }
        locationManager.stopUpdatingLocation()
    }
    @objc func updateCounter() {
        // Calculate total time since timer started in seconds
        time = Date().timeIntervalSinceReferenceDate - startTime
        // Calculate minutes
        let minutes = UInt8(time / 60.0)
        time -= (TimeInterval(minutes) * 60)
        // Calculate seconds
        let seconds = UInt8(time)
        time -= TimeInterval(seconds)
        // Format time vars with leading zero
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        // Add time vars to relevant labels
        labelMinute.text = strMinutes
        labelSecond.text = strSeconds
    }
    func prettify() {
        let origImage = UIImage(named: "icons8-marker-filled-50")
        let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        //centerLocationButtonContainer.layer.cornerRadius = 5
        centerLocationButtonContainer.roundCorners([.topRight, .topLeft, .bottomRight, .bottomLeft], radius: 5)
        //centerLocationButtonContainer.layer.borderWidth = 0.5
        self.centerLocationButton.setImage(tintedImage, for: .normal)
        self.centerLocationButton.tintColor = self.view.tintColor
        blurredContainer.roundCorners([.topRight, .topLeft], radius: 3)
        stopButton.layer.cornerRadius = 10
        progressBar.transform  = CGAffineTransform(scaleX: 1, y: 4)

    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if traveledDistance == 0 {
            lastLocation = startLocation
        }
        let location = locations.last
        traveledDistance += (lastLocation?.distance(from: location!))!
        lastLocation = location
        UIView.animate(withDuration: 0.5) {
            self.progressBar.setProgress(Float(self.traveledDistance/self.selectedRoute!.distance), animated: true)
        }
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        //print("entered region" + region.description)
        if region.identifier == "start" && visitedDogbags > 0 {
            traveledDistance = selectedRoute!.distance
            stopButton.sendActions(for: .touchUpInside)
        } else {
            visitedDogbags += 1
            updatePoobagCounter()
        }
    }
    func updatePoobagCounter() {
        dogBagProgressLabel.text = visitedDogbags.description + "/" + (selectedRoute!.dogBagCount).description
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        generator.impactOccurred()
        generator.impactOccurred()
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = self.view.tintColor
        renderer.lineWidth = 4.0
        return renderer
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueSummary" {
            // swiftlint:disable force_cast
            let popup = segue.destination as! SummaryViewController
            popup.route = selectedRoute!
            popup.travelledDistance = traveledDistance
            popup.walkedDuration = Date().timeIntervalSinceReferenceDate - startTime
            popup.timestamp = NSDate().timeIntervalSince1970
            popup.visitedDogbags = visitedDogbags
            // swiftlint:enable force_cast
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(fetchNotificaitonSummary as Any)
    }
}

extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

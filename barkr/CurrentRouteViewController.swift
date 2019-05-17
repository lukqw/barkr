//
//  CurrentRouteViewController.swift
//  barkr
//
//  Created by Tan Yücel on 16.05.19.
//  Copyright © 2019 luk. All rights reserved.
//

import UIKit
import MapKit

class CurrentRouteViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var blurredContainer: UIVisualEffectView!
    @IBOutlet weak var stopButton: UIButton!
    var selectedRoute: Route?
    override func viewDidLoad() {
        super.viewDidLoad()
        prettify()
        mapView.delegate = self
        for route in selectedRoute!.routes {
            self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
        }
        mapView.register(DogBagView.self, forAnnotationViewWithReuseIdentifier:  MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.showAnnotations(selectedRoute!.dogBags, animated: true)
        mapView?.userTrackingMode = .followWithHeading
        mapView?.showsCompass = true
        let span = MKCoordinateSpan(latitudeDelta: 0.0008, longitudeDelta: 0.0008)
        let sourceLocation = mapView.userLocation.location?.coordinate
        let mapRegion = MKCoordinateRegion(center: sourceLocation.unsafelyUnwrapped, span: span)
        mapView.setRegion(mapRegion, animated: true)
    }
    func prettify() {
        blurredContainer.roundCorners([.topRight, .topLeft], radius: 10)
        stopButton.layer.cornerRadius = 10
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
            // swiftlint:enable force_cast
        }
    }
}

extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds,
                                byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

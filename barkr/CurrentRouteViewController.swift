//
//  CurrentRouteViewController.swift
//  barkr
//
//  Created by Tan Yücel on 16.05.19.
//  Copyright © 2019 luk. All rights reserved.
//

import UIKit
import MapKit

class CurrentRouteViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var blurredContainer: UIVisualEffectView!
    @IBOutlet weak var stopButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        prettify()
        mapView.userTrackingMode = .follow
        mapView.showsCompass = true
    }
    func prettify() {
        blurredContainer.roundCorners([.topRight, .topLeft], radius: 10)
        stopButton.layer.cornerRadius = 10
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

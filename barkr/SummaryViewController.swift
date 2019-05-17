//
//  SummaryViewController.swift
//  barkr
//
//  Created by luk on 5/17/19.
//  Copyright © 2019 luk. All rights reserved.
//

import UIKit

class SummaryViewController: UIViewController {

    @IBOutlet var summaryView: UIView!
    var route = Route(time: 0, dogBagCount: 0, distance: 0)
    var isFav = false

    @IBOutlet var dogbagLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var resultLabel: UILabel!
    @IBOutlet var favButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.summaryView.layer.cornerRadius = 20
        dogbagLabel.text = String(route.dogBagCount)
        distanceLabel.text = String(route.distance/1000) + ","
                            + String(route.distance%1000/100)
                            + String(route.distance%100/10) + " km"
        timeLabel.text = String(route.time) + " min"
        resultLabel.text = "Your time: 27 Minutes"
    }

    @IBAction func doneButtonPressd(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "summaryDone"), object: self)
        })
    }

    @IBAction func favoriteButtonPressed(_ sender: Any) {
        if isFav {
            favButton.setImage(UIImage(named: "star"), for: .normal)
        } else {
            favButton.setImage(UIImage(named: "notstar"), for: .normal)
        }
        isFav = !isFav
    }

}

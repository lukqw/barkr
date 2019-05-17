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

    @IBOutlet var dogbagLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var resultLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.summaryView.layer.cornerRadius = 20
        dogbagLabel.text = String(route.dogBagCount)
        distanceLabel.text = String(route.distance/1000) + ","
            + String(route.distance%1000/100)
            + String(route.distance%100/10) + " km"
        timeLabel.text = String(route.time) + " min"
        resultLabel.text = "Your time: 27 Minutes"
        // Do any additional setup after loading the view.
    }

    @IBAction func doneButtonPressd(_ sender: Any) {
        dismiss(animated: true)
        self.navigationController?.popToRootViewController(animated: true)
    }

}

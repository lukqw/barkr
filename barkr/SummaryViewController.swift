//
//  SummaryViewController.swift
//  barkr
//
//  Created by luk on 5/17/19.
//  Copyright © 2019 luk. All rights reserved.
//

import UIKit
import RealmSwift

class SummaryViewController: UIViewController {

    @IBOutlet var summaryView: UIView!
    var route = Route(0, 0, 0)
    var isFav = false
    var timestamp: Double = 0
    var travelledDistance: Double = 0
    var walkedDuration: Double = 0
    var visitedDogbags: Int = 0
    @IBOutlet var dogbagLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var resultLabel: UILabel!
    @IBOutlet var favButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.summaryView.layer.cornerRadius = 20
        dogbagLabel.text = String(visitedDogbags) + "/" + String(route.dogBagCount)
        distanceLabel.text = route.distanceToString()
        timeLabel.text = String(route.time) + " min"
        resultLabel.text = "You walked " + distanceToString(Int(travelledDistance))
            + " in " + durationToString(walkedDuration) + " minutes!"
        resultLabel.lineBreakMode = .byWordWrapping
        resultLabel.numberOfLines = 0
        isFav = route.favorite
        setFavButton()
    }

    @IBAction func doneButtonPressd(_ sender: Any) {
        print(timestamp)
        let walkedRoute = WalkedRoute()
        walkedRoute.routeId = route.id
        walkedRoute.duration = walkedDuration
        walkedRoute.dogbags = visitedDogbags
        walkedRoute.timestamp = timestamp
        walkedRoute.distance = travelledDistance
        print(route)
        // swiftlint:disable force_try
        let realm = try! Realm()
        try! realm.write {
            realm.add(walkedRoute)
            realm.add(route)
        }
        // swiftlint:enable force_cast
        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "summaryDone"), object: self)
        })
    }

    func setFavButton() {
        if isFav {
            favButton.setImage(UIImage(named: "star"), for: .normal)
        } else {
            favButton.setImage(UIImage(named: "notstar"), for: .normal)
        }
    }
    @IBAction func favoriteButtonPressed(_ sender: Any) {
        isFav = !isFav
        setFavButton()
        // swiftlint:disable force_try
        let realm = try! Realm()
        try! realm.write {
            route.favorite = isFav
        }
        // swiftlint:enable force_cast
        print(route)
    }
    func distanceToString(_ distance: Int) -> String {
        return String(distance/1000) + ","
            + String(distance%1000/100)
            + String(distance%100/10) + " km"
    }

    func durationToString(_ duration: Double) -> String {
        //print(duration)
        var time = duration
        let minutes = UInt8(time / 60.0)
        time -= (TimeInterval(minutes) * 60)
        // Calculate seconds
        let seconds = UInt8(time)
        time -= TimeInterval(seconds)
        // Format time vars with leading zero
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        return strMinutes + ":" + strSeconds
    }
}

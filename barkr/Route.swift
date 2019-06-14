//
//  Route.swift
//  barkr
//
//  Created by luk on 5/14/19.
//  Copyright © 2019 luk. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

class Route: Object {

    @objc dynamic var id: Int = 0
    @objc dynamic var time: Int = 0
    @objc dynamic var dogBagCount: Int = 0
    @objc dynamic var distance: Double = 0.0
    var routes: [MKRoute] = []
    let dogBags = List<DogBagRealmObject>()
    //@objc dynamic var dogBags: [DogBagRealmObject] = []
    @objc dynamic var favorite: Bool = false
    convenience init(_ time: Int, _ dogBagCount: Int, _ distance: Double) {
        self.init(-1, time, dogBagCount, distance, false)
    }

    convenience init(_ id: Int, _ time: Int, _ dogBagCount: Int, _ distance: Double, _ favorite: Bool) {
        self.init()
        self.id = incrementID()
        self.time = time
        self.dogBagCount = dogBagCount
        self.distance = distance
        self.favorite = favorite
    }
    func calculateLength() {
        if routes.count != 0 {
            distance = 0
            for route in routes {
                distance += route.distance.magnitude
            }
        }
    }
    func distanceToString() -> String {
        let dist = Int(distance)
        return String(dist/1000) + ","
            + String(dist%1000/100)
            + String(dist%100/10) + " km"
    }
    override static func primaryKey() -> String? {
        return "id"
    }
    override static func ignoredProperties() -> [String] {
        return ["routes"]
    }
    func getDogbagArray() -> [DogBag] {
        var dogbags: [DogBag] = []
        for dbro in self.dogBags {
            dogbags.append(dbro.dogbag)
        }
        return dogbags
    }
    func setDogbagArray(_ arr: [DogBag]) {
        dogBags.removeAll()
        for dogbag in arr {
            let dbro = DogBagRealmObject.init()
            dbro.latitude = dogbag.coordinate.latitude
            dbro.longitude = dogbag.coordinate.longitude
            dogBags.append(dbro)
        }
    }
    func incrementID() -> Int {
        // swiftlint:disable force_try
        let realm = try! Realm()
        // swiftlint:enable force_try
        return (realm.objects(Route.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
}

//
//  RoutesViewController.swift
//  barkr
//
//  Created by luk on 5/10/19.
//  Copyright © 2019 luk. All rights reserved.
//

import UIKit

class RoutesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var historyRoutes: [Route] = [Route(time: 30, dogBagCount: 4, distance: 5300),
                               Route(time: 27, dogBagCount: 4, distance: 5025),
                               Route(time: 33, dogBagCount: 4, distance: 5740),
                               Route(time: 34, dogBagCount: 3, distance: 5800),
                               Route(time: 23, dogBagCount: 4, distance: 4700),
                               Route(time: 26, dogBagCount: 2, distance: 4900)]
    var favoriteRoutes: [Route] = [Route(time: 30, dogBagCount: 4, distance: 5300),
                                  Route(time: 27, dogBagCount: 4, distance: 5025)]

    @IBOutlet weak var routesSegmentedControl: UISegmentedControl!
    @IBOutlet weak var routesTableView: UITableView!

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch routesSegmentedControl.selectedSegmentIndex {
        case 0:
            return favoriteRoutes.count
        case 1:
            return historyRoutes.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let routesCell = tableView.dequeueReusableCell(withIdentifier: "routesCell")
        switch routesSegmentedControl.selectedSegmentIndex {
        case 0:
            let cell = routesTableView.dequeueReusableCell(withIdentifier: "routesCell", for: indexPath)
                // swiftlint:disable force_cast
                as! RouteSelectionCell
            // swiftlint:enable force_cast
            let route = favoriteRoutes[indexPath.row]
            cell.timeLabel?.text = String(route.time) + " min"
            cell.bagFlagLabel?.text = String(route.dogBagCount)
            cell.distanceLabel?.text = String(route.distance/1000) + ","
                + String(route.distance%1000/100)
                + String(route.distance%100/10) + " km"
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor(red: 0.17, green: 0.55, blue: 0.22, alpha: 0.20)
            cell.selectedBackgroundView = backgroundView
            return cell
        case 1:
            let cell = routesTableView.dequeueReusableCell(withIdentifier: "routesCell", for: indexPath)
                // swiftlint:disable force_cast
                as! RouteSelectionCell
            // swiftlint:enable force_cast
            let route = historyRoutes[indexPath.row]
            cell.timeLabel?.text = String(route.time) + " min"
            cell.bagFlagLabel?.text = String(route.dogBagCount)
            cell.distanceLabel?.text = String(route.distance/1000) + ","
                + String(route.distance%1000/100)
                + String(route.distance%100/10) + " km"
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor(red: 0.17, green: 0.55, blue: 0.22, alpha: 0.20)
            cell.selectedBackgroundView = backgroundView
            return cell
        default:
            break
        }
        return routesCell.unsafelyUnwrapped
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if routesSegmentedControl.selectedSegmentIndex == 0 {
                favoriteRoutes.remove(at: indexPath.row)
            } else {
                historyRoutes.remove(at: indexPath.row)
            }
            routesTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    @IBAction func routesSegmentedControlPressed(_ sender: Any) {
        routesTableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(toggleEditing))
        self.navigationItem.rightBarButtonItem = editButton
    }
    @objc private func toggleEditing() {
        routesTableView.setEditing(!routesTableView.isEditing, animated: true)
        navigationItem.rightBarButtonItem?.title = routesTableView.isEditing ? "Done" : "Edit"
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showRouteSelectionSegue" {
            // swiftlint:disable force_cast
           let nextView = segue.destination as! RouteSelectionViewController
            nextView.routeOverviewOnly = true
        let num: Int = routesTableView.indexPathForSelectedRow!.row
        nextView.routeArray = [historyRoutes[num]]
            // swiftlint:enable force_cast
  //      }
    }

    override func unwind(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
        if unwindSegue.identifier == "showRouteSelectionSegue" {
            viewWillAppear(true)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

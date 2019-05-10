//
//  RoutesViewController.swift
//  barkr
//
//  Created by luk on 5/10/19.
//  Copyright © 2019 luk. All rights reserved.
//

import UIKit

class RoutesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let favoriteRoutes: [String] = ["FavoritesTest", "FavoritesTest1"]
    let historyRoutes: [String] = ["HistoryTest2", "HistoryTest3"]

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
            routesCell?.textLabel!.text = favoriteRoutes[indexPath.row]
        case 1:
            routesCell?.textLabel!.text = historyRoutes[indexPath.row]
        default:
            break
        }
        return routesCell.unsafelyUnwrapped
    }

    @IBAction func routesSegmentedControlPressed(_ sender: Any) {
        routesTableView.reloadData()
    }

    @IBAction func editRoutesPressed(_ sender: Any) {

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

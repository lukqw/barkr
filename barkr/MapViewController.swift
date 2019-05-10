//
//  MapViewController.swift
//  barkr
//
//  Created by luk on 5/10/19.
//  Copyright © 2019 luk. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapButton: UIButton!
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
    @IBAction func mapButtonPressed(_ sender: Any) {
        mapButton.setTitle("test", for: UIControl.State.normal)
    }

}

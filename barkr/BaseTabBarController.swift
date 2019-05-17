//
//  BaseTabBarController.swift
//  barkr
//
//  Created by luk on 5/12/19.
//  Copyright © 2019 luk. All rights reserved.
//

import UIKit

class BaseTabBarController: UITabBarController {

    @IBInspectable var defaultIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = defaultIndex
    }
}

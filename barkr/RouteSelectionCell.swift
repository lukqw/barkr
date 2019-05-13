//
//  RouteSelectionCell.swift
//  barkr
//
//  Created by luk on 5/13/19.
//  Copyright © 2019 luk. All rights reserved.
//

import FoldingCell
import UIKit

class RouteSelectionCell: FoldingCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var bagFlagLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!

    var number: Int = 0 {
        didSet {
            timeLabel.text = String(number)
            distanceLabel.text = String(number)
        }
    }

    override func awakeFromNib() {
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        super.awakeFromNib()
    }

    override func animationDuration(_ itemIndex: NSInteger, type _: FoldingCell.AnimationType) -> TimeInterval {
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }

}

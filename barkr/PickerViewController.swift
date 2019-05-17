//
//  PickerViewController.swift
//  barkr
//
//  Created by luk on 5/16/19.
//  Copyright © 2019 luk. All rights reserved.
//

import UIKit

class PickerViewController: UIViewController {

    @IBOutlet weak var pickerContainerView: UIView!
    @IBOutlet weak var pickerContainerDone: UIButton!
    @IBOutlet weak var pickerContainerCancel: UIButton!
    @IBOutlet var minOrKmPicker: UIPickerView!
    @IBOutlet var minOrKmLabel: UILabel!

    var isKm: Bool = false
    var value: Int = 30

    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickerContainerView.layer.cornerRadius = 20
        minOrKmPicker.selectRow(value-1, inComponent: 0, animated: false)
        minOrKmLabel.text = isKm ? "Km" : "Min"
    }

    @IBAction func pickerValueCancelled(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func pickerValueSelected(_ sender: Any) {
        value = minOrKmPicker.selectedRow(inComponent: 0) + 1
        NotificationCenter.default.post(name: Notification.Name(rawValue: "valuePicker"), object: self)
        dismiss(animated: true)
    }

}

extension PickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch isKm {
        case false:
            return 180
        case true:
            return 10
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (row + 1).description
    }
}

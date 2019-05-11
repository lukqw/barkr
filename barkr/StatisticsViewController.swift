//
//  StatisticsViewController.swift
//  barkr
//
//  Created by Tan Yücel on 10.05.19.
//  Copyright © 2019 luk. All rights reserved.
//

import UIKit
import Charts

class StatisticsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
        let statisticsCategoryTitles: [String] = ["Weekly Total", "Distance Walked",
                                   "Average Duration", "Walked the Dog", "Dogbag Donator Sum"]
    
    let statisticsCategoryValues: [String] = ["9h 30m", "23 km", "23 min", "13 times", "29 dogbags"]
    @IBOutlet weak var statisticsTableView: UITableView!
    @IBOutlet weak var barChartView: BarChartView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statisticsCategoryTitles.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let statisticsCell = tableView.dequeueReusableCell(withIdentifier: "statisticsCell")
        statisticsCell?.textLabel!.text = statisticsCategoryTitles[indexPath.row]
        let label = UILabel.init(frame: CGRect(x:0, y:0, width:100, height:20))
        label.text = statisticsCategoryValues[indexPath.row]
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.sizeToFit()
        statisticsCell?.accessoryView = label
        return statisticsCell.unsafelyUnwrapped
    }
    override func viewDidLoad() {
        super.viewDidLoad()
                // Do any additional setup after loading the view.
        setChartData()
        self.statisticsTableView.tableFooterView = UIView()

    }
    
    func setChartData(_ count: Int = 7){
        let values = (0..<count).map { (iii) -> ChartDataEntry in
            let val = Double(arc4random_uniform(150))/100
            return BarChartDataEntry(x: Double(iii), y: val)
        }
        let set1 = BarChartDataSet(entries: values, label: "Test")
        let data = BarChartData(dataSet: set1)
        // Do any additional setup after loading the vie
        barChartView.drawBarShadowEnabled = false
        barChartView.drawGridBackgroundEnabled = false
        barChartView.drawValueAboveBarEnabled = true
        barChartView.maxVisibleCount = 60
        let xAxis = barChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.granularity = 1
        xAxis.labelCount = 7
        xAxis.valueFormatter = Formatter.init()
            barChartView.leftAxis.enabled = false
        barChartView.rightAxis.enabled = false
        barChartView.legend.enabled = false
        
        self.barChartView.data = data
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

class Formatter: IAxisValueFormatter {
    let activities = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return activities[Int(value) % activities.count]
}
}

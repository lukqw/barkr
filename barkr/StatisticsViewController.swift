//
//  StatisticsViewController.swift
//  barkr
//
//  Created by Tan Yücel on 10.05.19.
//  Copyright © 2019 luk. All rights reserved.
//

import UIKit
import Charts
import RealmSwift

class StatisticsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let statisticsCategoryTitles: [String] = ["Times Walked", "Total Walk Time", "Average Walk Time",
                                              "Total Walk Distance", "Average Walk Distance", "Passed Poo Bag Stations"]
    let statisticsCategoryValues: [String] = ["10x", "9h 30m", "24 min", "23 km", "2.7km", "29"]
    var currentDate = Date()
    @IBOutlet weak var statisticsTableView: UITableView!
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var barChartContainerView: UIView!
    @IBOutlet weak var previousWeekButton: UIButton!
    @IBOutlet weak var nextWeekButton: UIButton!
    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var averageDurationLabel: UILabel!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statisticsCategoryTitles.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let statisticsCell = tableView.dequeueReusableCell(withIdentifier: "statisticsCell")
        statisticsCell?.textLabel!.text = statisticsCategoryTitles[indexPath.row]
        let label = UILabel.init(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        label.text = statisticsCategoryValues[indexPath.row]
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.sizeToFit()
        statisticsCell?.accessoryView = label
        return statisticsCell.unsafelyUnwrapped
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.statisticsTableView.alwaysBounceVertical = false
        self.statisticsTableView.sizeToFit()
        self.barChartContainerView.sizeToFit()
        self.nextWeekButton.isEnabled = false
        self.barChartContainerView.layer.borderWidth = 0.5
        self.barChartContainerView.layer.borderColor = UIColor.init(white: 0.8, alpha: 1).cgColor
        self.statisticsTableView.layer.borderWidth = 0.5
        self.statisticsTableView.layer.borderColor = UIColor.init(white: 0.8, alpha: 1).cgColor
        self.statisticsTableView.isUserInteractionEnabled = false
        var origImage = UIImage(named: "icons8-back-filled-50")
        var tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.previousWeekButton.setImage(tintedImage, for: .normal)
        self.previousWeekButton.tintColor = self.view.tintColor
        origImage = UIImage(named: "icons8-forward-filled-50")
        tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.nextWeekButton.setImage(tintedImage, for: .normal)
        self.nextWeekButton.tintColor = self.view.tintColor
        self.previousWeekButton.backgroundRect(forBounds: CGRect.init(x: 0, y: 0, width: 25, height: 25))
        // swiftlint:disable force_try
        let realm = try! Realm()
        // swiftlint:enable force_try
        let data = realm.objects(WalkedRoute.self)
        print(data)
        initializeBarChartView()
        setChartData()
    }
    func initializeBarChartView() {
        barChartView.drawBarShadowEnabled = false
        barChartView.drawGridBackgroundEnabled = false
        barChartView.drawValueAboveBarEnabled = true
        barChartView.maxVisibleCount = 60
        //barChartView.highlightPerTapEnabled = true
        //barChartView.isUserInteractionEnabled = false
        let xAxis = barChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.granularity = 1
        xAxis.labelCount = 7
        xAxis.valueFormatter = Formatter.init()
        xAxis.drawGridLinesEnabled = false
        barChartView.drawMarkers = true
        barChartView.leftAxis.enabled = false
        barChartView.rightAxis.enabled = true
        barChartView.rightAxis.drawGridLinesEnabled = false
        barChartView.rightAxis.drawAxisLineEnabled = false
        barChartView.legend.enabled = false
    }
    //so far this will only randomize the chart data
    func setChartData(_ count: Int = 7) {
        barChartView.clear()
        barChartView.rightAxis.removeAllLimitLines()
        var avgDuration: Double = 0
        let values = (0..<count).map {(iii) -> ChartDataEntry in
            let val = Double(arc4random_uniform(150))/100
            avgDuration += val
            return BarChartDataEntry(x: Double(iii), y: val)
        }
        avgDuration /= Double(count)
        let set = BarChartDataSet(entries: values, label: "Test")
        let data = BarChartData(dataSet: set)
        set.setColor(UIColor(red: 0x2b/255, green: 0x8b/255, blue: 0x38/255, alpha: 1))
        set.highlightEnabled = false
        set.label = "test"
        set.drawValuesEnabled = false
        //set.highlightEnabled = true
        let avgLine = ChartLimitLine(limit: avgDuration)
        avgLine.drawLabelEnabled = false
        avgLine.lineColor = NSUIColor.init(white: 0.2, alpha: 1)
        avgLine.lineWidth = 0.2
        avgLine.lineDashLengths = [3, 3]
        barChartView.rightAxis.addLimitLine(avgLine)
        avgDuration = Double(round(100*avgDuration)/100)
        averageDurationLabel.text = (Int(floor(avgDuration)).description + "h " +
            Int((60 * (avgDuration.truncatingRemainder(dividingBy: 1)))).description + "min")
        let nFrmtr = NumberFormatter.init()
        nFrmtr.minimumIntegerDigits = 1
        nFrmtr.minimumFractionDigits = 1
        barChartView.rightAxis.valueFormatter = DefaultAxisValueFormatter.init(formatter: nFrmtr)
        self.barChartView.data = data
        changeCurrentWeekLabel()
        barChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
    }

    @IBAction func prev(_ sender: Any) {
        nextWeekButton.isEnabled = true
        currentDate = Calendar.current.date(byAdding: .day, value: -7, to: currentDate)!
        setChartData()
    }
    @IBAction func next(_ sender: Any) {
        currentDate = Calendar.current.date(byAdding: .day, value: 7, to: currentDate)!
        if currentDate.totalDistance(from: Date(), resultIn: .day) == 0 {
            nextWeekButton.isEnabled = false
        }
        setChartData()
    }
    func changeCurrentWeekLabel() {
        let format = DateFormatter()
        format.dateFormat = "w"
        let formattedDate = format.string(from: currentDate)
        weekLabel.text = "Week " + formattedDate
    }
}

class Formatter: IAxisValueFormatter {
    let activities = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return activities[Int(value) % activities.count]
    }
}

import Foundation

extension Date {
    func totalDistance(from date: Date, resultIn component: Calendar.Component) -> Int? {
        return Calendar.current.dateComponents([component], from: self, to: date).value(for: component)
    }
    func compare(with date: Date, only component: Calendar.Component) -> Int {
        let days1 = Calendar.current.component(component, from: self)
        let days2 = Calendar.current.component(component, from: date)
        return days1 - days2
    }
    func hasSame(_ component: Calendar.Component, as date: Date) -> Bool {
        return self.compare(with: date, only: component) == 0
    }
}

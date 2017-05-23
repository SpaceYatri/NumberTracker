//
//  ViewController.swift
//  NumberTracker
//
//  Created by Sushant Tiwari on 23/05/17.
//  Copyright © 2017 Sushant Tiwari. All rights reserved.
//

import UIKit
import SocketIO
import Charts
import UserNotifications

let serverName = URL(string: "http://ios-test.us-east-1.elasticbeanstalk.com/")
let nameSpace = "/random"
let socketEvent = "capture"

class ViewController: UIViewController, ChartViewDelegate {
    let socket = SocketHandler(socketURL: serverName!, namespace: nameSpace)
    var numberArray = [Int]()
    @IBOutlet weak var lineChart: LineChartView!
    let center = UNUserNotificationCenter.current()
    let options: UNAuthorizationOptions = [.alert, .sound]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerLocalNotif()
        lineChart.delegate = self
        socket.getInt(forEvent: socketEvent) {[weak self] randNum in
            guard let randomNumber = randNum else {
                return
            }
            self?.add(randomNumber: randomNumber)
        }
        
        lineChart.drawGridBackgroundEnabled = false
        lineChart.noDataText = "Connecting ..."
        lineChart.xAxis.axisMaximum = 9.0
        lineChart.xAxis.axisMinimum = 0.0
        lineChart.leftAxis.axisMaximum = 12.0
        lineChart.leftAxis.axisMinimum = 0.0
        lineChart.rightAxis.enabled = false
        lineChart.xAxis.drawLabelsEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func add(randomNumber: Int) {
        numberArray.insert(randomNumber, at: 0)
        scheduleLocalNotif()
        if(numberArray.count > 10) {
            numberArray.removeLast()
        }
        if(numberArray.count == 0 || numberArray.count > 10) {
            print("Should not run")
            return;
        }
        updateChart(data: numberArray)
    }
    
    func updateChart(data: [Int]) {
        var dataEntries: [ChartDataEntry] = [ChartDataEntry]()
        let count = numberArray.count
        for (index, value) in numberArray.enumerated() {
            //
            let dataEntry = ChartDataEntry(x: Double(count - index - 1), y: Double(value))
            dataEntries.insert(dataEntry, at: 0)
        }
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "Random Numbers")
        chartDataSet.axisDependency = .left // Line will correlate with left axis values
        chartDataSet.setColor(UIColor.red.withAlphaComponent(0.5))
        chartDataSet.lineWidth = 1.5
        chartDataSet.mode = .horizontalBezier
        chartDataSet.cubicIntensity = 0.5
        chartDataSet.drawCircleHoleEnabled = true
        chartDataSet.drawCirclesEnabled = true
        chartDataSet.circleHoleRadius = 2
        chartDataSet.circleRadius = 3
        chartDataSet.circleColors = [UIColor.red]
        
        
        var dataSets : [LineChartDataSet] = [LineChartDataSet]()
        dataSets.append(chartDataSet)
        
        let chartData = LineChartData(dataSets: dataSets)
        chartData.setValueTextColor(UIColor.white)
        lineChart.data = chartData
    }
    
    func setChartData(months : [String]) {
        
        // 1 - creating an array of data entries
        var yVals1 : [ChartDataEntry] = [ChartDataEntry]()
        for i in 0 ..< months.count {
            yVals1.append(ChartDataEntry(x: Double(i), y: Double(i)))
        }
        
        // 2 - create a data set with our array
        let set1: LineChartDataSet = LineChartDataSet(values: yVals1, label: "First Set")
        set1.axisDependency = .left // Line will correlate with left axis values
        set1.setColor(UIColor.red.withAlphaComponent(0.5)) // our line's opacity is 50%
        set1.setCircleColor(UIColor.red) // our circle will be dark red
        set1.lineWidth = 2.0
        set1.circleRadius = 6.0 // the radius of the node circle
        set1.fillAlpha = 65 / 255.0
        set1.fillColor = UIColor.red
        set1.highlightColor = UIColor.white
        set1.drawCircleHoleEnabled = true
        
        //3 - create an array to store our LineChartDataSets
        var dataSets : [LineChartDataSet] = [LineChartDataSet]()
        dataSets.append(set1)
        
        //4 - pass our months in for our x-axis label value along with our dataSets
        let data: LineChartData = LineChartData(dataSets: dataSets)
        data.setValueTextColor(UIColor.white)
        
        //5 - finally set our data
        self.lineChart.data = data
        
        
    }
    
    func registerLocalNotif() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in }
    }
    
    func scheduleLocalNotif() {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Duplicate Numbers"
        content.body = "Two consecutive same numbers are received"
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
}


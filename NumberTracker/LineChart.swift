//
//  LineChartView.swift
//  NumberTracker
//
//  Created by Sushant Tiwari on 24/05/17.
//  Copyright © 2017 Sushant Tiwari. All rights reserved.
//

import UIKit
import Charts

let colors = [UIColor(red: 255/255, green: 59/255,  blue: 48/255,  alpha: 1),
              UIColor(red: 255/255, green: 149/255, blue: 0/255,   alpha: 1),
              UIColor(red: 76/255,  green: 217/255, blue: 100/255, alpha: 1),
              UIColor(red: 90/255,  green: 200/255, blue: 250/255, alpha: 1),
              UIColor(red: 0/255,   green: 122/255, blue: 255/255, alpha: 1),
              UIColor(red: 88/255,  green: 86/255,  blue: 214/255, alpha: 1),
              UIColor(red: 255/255, green: 45/255,  blue: 85/255,  alpha: 1),
              UIColor(red: 255/255, green: 204/255, blue: 0/255,   alpha: 1)]

class LineChart: LineChartView {
    
    let chartColor: UIColor = colors[Int(arc4random()%8)]
    
    func setup() {
        drawGridBackgroundEnabled = false
        noDataText = "Connecting ..."
        xAxis.axisMaximum = 9.0
        xAxis.axisMinimum = 0.0
        leftAxis.axisMaximum = 10.0
        leftAxis.axisMinimum = 0.0
        rightAxis.enabled = false
        xAxis.drawLabelsEnabled = false
        chartDescription?.text = ""
    }
    
    func updateChart(withData data: [Int]) {
        var dataEntries: [ChartDataEntry] = [ChartDataEntry]()
        let count = data.count
        for (index, value) in data.enumerated() {
            //
            let dataEntry = ChartDataEntry(x: Double(count - index - 1), y: Double(value))
            dataEntries.insert(dataEntry, at: 0)
        }
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "Random Numbers")
        chartDataSet.axisDependency = .left // Line will correlate with left axis values
        chartDataSet.setColor(chartColor)
        chartDataSet.lineWidth = 1.5
        chartDataSet.mode = .horizontalBezier
        chartDataSet.cubicIntensity = 0.5
        chartDataSet.drawCircleHoleEnabled = true
        chartDataSet.drawCirclesEnabled = true
        chartDataSet.circleHoleRadius = 2
        chartDataSet.circleRadius = 3
        chartDataSet.circleColors = [chartColor]
        chartDataSet.drawValuesEnabled = false
        
        var dataSets : [LineChartDataSet] = [LineChartDataSet]()
        dataSets.append(chartDataSet)
        
        let chartData = LineChartData(dataSets: dataSets)
        chartData.setValueTextColor(UIColor.white)
        self.data = chartData
    }
    

}

//
//  DataVC.swift
//  Bird
//
//  Created by Arjun Madgavkar on 4/21/18.
//  Copyright © 2018 Arjun Madgavkar. All rights reserved.
//

import UIKit
import Disk
import Charts

class DataVC: UIViewController {
  // Properties
  let today = Date()
  var categories = [Category]()
  var activities = [Activity]()
  var timeBlocks = [TimeBlock]()
  // Outlets
  @IBOutlet weak var categoryPieChart: PieChartView!
  @IBOutlet weak var activityPieChart: PieChartView!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewControllerSetUp()
    dataPull()
    calculateCategoryData()
    calculateActivityData()  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(false)
  }
  
  func viewControllerSetUp() {
    categoryPieChart.noDataText = "No data: please add time blocks to your day and then come back!"
    categoryPieChart.legend.enabled = false
    categoryPieChart.drawHoleEnabled = false
    
    activityPieChart.noDataText = "No data: please add time blocks to your day and then come back!"
    activityPieChart.legend.enabled = false
    activityPieChart.drawHoleEnabled = false
  }
  
  func dataPull() {
    // Get data saved on Disk
    do { categories = try Disk.retrieve("categories.json", from: .documents, as: [Category].self) }
    catch let error { print("\(error)") }
    do { activities = try Disk.retrieve("activities.json", from: .documents, as: [Activity].self) }
    catch let error { print("\(error)") }
    do { timeBlocks = try Disk.retrieve("timeBlocks.json", from: .documents, as: [TimeBlock].self) }
    catch let error { print("\(error)") }
  }
  
  /*
   * First Date --> date from the earliest timeBlock added (example: april 19)
   * Get number of days between today and first date (don't include today yet) --> multiply by 24 = total hours since first date (example: 48 hours)
   * Each category keeps track of total hours spent --> every time a category is added to a timeBlock, we increment total hours based on duration
                                                    --> category.getTotalHours() / hoursSinceFirstDate = % of time spent on the category
   * Each activity keeps track of total hours spent --> every time an activity is added to a timeBlock, we increment total hours based on duration
                                                    --> activity.getTotalHours() / hoursSinceFirstDate = % of time spent on the activity
   * Quality --> go through each timeBlock --> if quality == 10 then add it to the quality10 array
             --> since we have a reference to each timeBlock, the user can click on a portion of the graph and get data about the timeBlocks for that quality
 */
  func calculateCategoryData() {
    var categoryData = [PieChartDataEntry]()
    if ( timeBlocks.count > 0 && categories.count > 0 ) {
      let earliestTimeBlock = TimeBlock.getEarliestTimeBlock()
      let numberOfDaysSinceFirstBlock = today.days(from: earliestTimeBlock.startDate)
      let totalHoursSinceFirstBlock: Double!
      if ( numberOfDaysSinceFirstBlock < 1 ) { // first day
        totalHoursSinceFirstBlock = 24
      } else {
        totalHoursSinceFirstBlock = Double(numberOfDaysSinceFirstBlock * 24)
      }
      
      print("Hours since first block:\(totalHoursSinceFirstBlock)")
      
      // Handle categories
      for category in categories {
        if ( category.getTotalHours() > 0 ) { // don't bother showing stuff that's 0%
          let percentageOfTime = Double(category.getTotalHours()/totalHoursSinceFirstBlock)
          let entry = PieChartDataEntry(value: percentageOfTime, label: category.getName())
          categoryData.append(entry)
        }
      }
      
      let chartDataSet = PieChartDataSet(values: categoryData, label: "")
      chartDataSet.colors = ChartColorTemplates.material()
      chartDataSet.sliceSpace = 2
      chartDataSet.selectionShift = 5
      
      let chartData = PieChartData(dataSet: chartDataSet)
      let formatter = NumberFormatter()
      formatter.numberStyle = .percent
      formatter.maximumFractionDigits = 0
      chartData.setValueFormatter(DefaultValueFormatter(formatter: formatter))
      
      categoryPieChart.data = chartData
      
    }
  }
  
  func calculateActivityData() {
    var activityData = [PieChartDataEntry]()
    if ( timeBlocks.count > 0 && activities.count > 0 ) {
      let earliestTimeBlock = TimeBlock.getEarliestTimeBlock()
      let numberOfDaysSinceFirstBlock = today.days(from: earliestTimeBlock.startDate)
      let totalHoursSinceFirstBlock: Double!
      if ( numberOfDaysSinceFirstBlock < 1 ) { // first day
        totalHoursSinceFirstBlock = 24
      } else {
        totalHoursSinceFirstBlock = Double(numberOfDaysSinceFirstBlock * 24)
      }
      
      print("Hours since first block:\(totalHoursSinceFirstBlock)")
      
      for activity in activities {
        if ( activity.getTotalHours() > 0 ) {
          let percentageOfTime = Double(activity.getTotalHours()/totalHoursSinceFirstBlock)
          let entry = PieChartDataEntry(value: percentageOfTime, label: activity.getName())
          activityData.append(entry)
        }
      }
      
      let chartDataSet = PieChartDataSet(values: activityData, label: "")
      chartDataSet.colors = ChartColorTemplates.material()
      chartDataSet.sliceSpace = 2
      chartDataSet.selectionShift = 5
      
      let chartData = PieChartData(dataSet: chartDataSet)
      let formatter = NumberFormatter()
      formatter.numberStyle = .percent
      formatter.maximumFractionDigits = 0
      chartData.setValueFormatter(DefaultValueFormatter(formatter: formatter))
      
      activityPieChart.data = chartData
    }
    
    
    
  }
  

}

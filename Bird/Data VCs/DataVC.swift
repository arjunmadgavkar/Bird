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
  var timeBlocks = [TimeBlock]()
  // Outlets
  @IBOutlet weak var pieChartView: PieChartView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    dataPull()
    calculateData()
  }
  
  func dataPull() {
    // Get data saved on Disk
    do { categories = try Disk.retrieve("categories.json", from: .documents, as: [Category].self) }
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
  func calculateData() {
    if ( timeBlocks.count > 0 ) {
      let earliestTimeBlock = TimeBlock.getEarliestTimeBlock()
      let numberOfDaysSinceFirstBlock = today.days(from: earliestTimeBlock.startDate)
      let totalHoursSinceFirstBlock = numberOfDaysSinceFirstBlock * 24
      print("Hours since first block:\(totalHoursSinceFirstBlock)")
    }
    
    
    
  }
  
  


  

}

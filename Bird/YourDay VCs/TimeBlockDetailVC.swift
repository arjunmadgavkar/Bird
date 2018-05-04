//
//  TimeBlockDetailVC.swift
//  Bird
//
//  Created by Arjun Madgavkar on 4/12/18.
//  Copyright © 2018 Arjun Madgavkar. All rights reserved.
//

import UIKit

class TimeBlockDetailVC: UIViewController {
  var timeBlock: TimeBlock?
  let userCalendar = Calendar.current
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var activityLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var qualityLabel: UILabel!
  @IBOutlet weak var flowLabel: UILabel!
  @IBOutlet weak var unpleasantFeelingsLabel: UILabel!
  @IBOutlet weak var notesLabel: UILabel!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewControllerSetUp()
  }
  
  func viewControllerSetUp() {
    notesLabel.numberOfLines = 0 // Label has mult lines
    
    // Add data to labels
    if ( timeBlock != nil ) { // Make sure timeBlock was passed
      let startTime = userCalendar.dateComponents(in: userCalendar.timeZone, from: (timeBlock?.startDate)!)
      let endTime = userCalendar.dateComponents(in: userCalendar.timeZone, from: (timeBlock?.endDate)!)
      categoryLabel.text = timeBlock?.category.name // Category
      activityLabel.text = timeBlock?.activity.name // Activity
      timeLabel.text = dateRangeToString(startDate: startTime, endDate: endTime)
      dateLabel.text = "\(startTime.month!)/\(startTime.day!)/\(startTime.year!)"
      if let quality = timeBlock?.quality {
        qualityLabel.text = String(describing: quality)
      } else { qualityLabel.text = "Empty" }
      flowLabel.text = (timeBlock?.flow)! ? "Yes" : "No"
      unpleasantFeelingsLabel.text = (timeBlock?.unpleasantFeelings)! ? "Yes" : "No"
      notesLabel.text = (timeBlock?.notes)!
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let navVC = segue.destination as! UINavigationController
    let editVC = navVC.topViewController as! EditTimeBlockVC
    editVC.timeBlock = timeBlock! // editVC's timeBlock has a reference to the OG timeBlock
  }
  
  
}

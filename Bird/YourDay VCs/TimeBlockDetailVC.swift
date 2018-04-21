//
//  TimeBlockDetailVC.swift
//  Bird
//
//  Created by Arjun Madgavkar on 4/12/18.
//  Copyright © 2018 Arjun Madgavkar. All rights reserved.
//

import UIKit

class TimeBlockDetailVC: UIViewController {
  let usercalendar = Calendar.current
  var timeBlock: TimeBlock?
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var activityLabel: UILabel!
  @IBOutlet weak var startTimeLabel: UILabel!
  @IBOutlet weak var endTimeLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var qualityLabel: UILabel!
  @IBOutlet weak var flowLabel: UILabel!
  @IBOutlet weak var unpleasantFeelingsLabel: UILabel!
  @IBOutlet weak var accomplishmentsLabel: UILabel!
  @IBOutlet weak var learningsLabel: UILabel!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewControllerSetUp()
  }
  
  func viewControllerSetUp() {
    accomplishmentsLabel.numberOfLines = 0 // Label has mult lines
    learningsLabel.numberOfLines = 0 // Label has mult lines
    
    // Add data to labels
    var startTime, endTime: DateComponents! // Mark: Caution
    if ( timeBlock != nil ) { // Make sure timeBlock was passed
      categoryLabel.text = timeBlock?.category.name
      activityLabel.text = timeBlock?.activity
      startTime = usercalendar.dateComponents(in: usercalendar.timeZone, from: (timeBlock?.startDate)!)
      startTimeLabel.text = String(describing: startTime.hour!) // Use exclamation to tell Swift again this isn't optional
      endTime = usercalendar.dateComponents(in: usercalendar.timeZone, from: (timeBlock?.endDate)!)
      endTimeLabel.text = String(describing: endTime.hour!)
      dateLabel.text = String(describing: startTime.month!) + "/" + String(describing: startTime.day!) + "/" + String(describing: startTime.year!)
      if let quality = timeBlock?.quality {
        qualityLabel.text = String(describing: quality)
      } else { qualityLabel.text = "Empty" }
      flowLabel.text = (timeBlock?.flow)! ? "Yes" : "No"
      unpleasantFeelingsLabel.text = (timeBlock?.unpleasantFeelings)! ? "Yes" : "No"
      accomplishmentsLabel.text = (timeBlock?.accomplishments)!
      learningsLabel.text = (timeBlock?.learnings)!
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let navVC = segue.destination as! UINavigationController
    let editVC = navVC.topViewController as! EditTimeBlockVC
    editVC.timeBlock = timeBlock! // editVC's timeBlock has a reference to the OG timeBlock
  }
  
  
}

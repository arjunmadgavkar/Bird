//
//  GoalDetailVC.swift
//  Bird
//
//  Created by Arjun Madgavkar on 4/21/18.
//  Copyright © 2018 Arjun Madgavkar. All rights reserved.
//

import UIKit

class GoalDetailVC: UIViewController {
  var goal: Goal!
  // Outlets
  @IBOutlet weak var currentStreakLabel: UILabel!
  @IBOutlet weak var longestStreakLabel: UILabel!
  @IBOutlet weak var completionRateLabel: UILabel!
  @IBOutlet weak var totalCompletionsLabel: UILabel!
  

  override func viewDidLoad() {
    super.viewDidLoad()
    viewControllerSetUp()
  }
  
  func viewControllerSetUp() {
    navigationItem.largeTitleDisplayMode = .never // No large title
    currentStreakLabel.text = "\(goal.getCurrentStreak())"
    longestStreakLabel.text = "\(goal.getLongestStreak())"
    let percentage = goal.getPercentageComplete()
    completionRateLabel.text = String(format: "%.1f", percentage) + "%"
    totalCompletionsLabel.text = "\(goal.getNumberOfCompletions())"
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let navVC = segue.destination as! UINavigationController
    let editGoalVC = navVC.topViewController as! EditGoalVC
    editGoalVC.goal = goal
  }
  
}

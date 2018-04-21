//
//  EditGoalVC.swift
//  Bird
//
//  Created by Arjun Madgavkar on 4/21/18.
//  Copyright © 2018 Arjun Madgavkar. All rights reserved.
//

import UIKit
import Eureka
import Disk

class EditGoalVC: FormViewController {
  var goal: Goal!
  var goals = [Goal]()

  override func viewDidLoad() {
    super.viewDidLoad()
    dataPull()
    setUpForm()
  }
  
  func dataPull() {
    do { goals = try Disk.retrieve("goals.json", from: .documents, as: [Goal].self) }
    catch let error { print("\(error)") }
  }
  
  func setUpForm() {
    NameRow.defaultCellSetup = { cell, row in
      cell.textLabel?.font = AvenirNext(size: 17.0)
      cell.textField?.font = AvenirNext(size: 17.0)
    }
    IntRow.defaultCellSetup = { cell, row in
      cell.textLabel?.font = AvenirNext(size: 17.0)
      cell.textField?.font = AvenirNext(size: 17.0)
    }
    ButtonRow.defaultCellSetup = {cell, row in
      cell.textLabel?.font = AvenirNext(size: 20.0)
      cell.textLabel?.textColor = UIColor(rgb: 0x060A78).withAlphaComponent(1.0)
    }

    form
      // Goal
      +++ Section("New Goal")
      <<< NameRow(){ row in
        row.title = "Goal"
        row.tag = "goal"
        row.value = goal.name
      }
      // Time
      <<< IntRow(){ row in
        row.title = "Hours per Day"
        row.tag = "time"
        row.value = Int(goal.timePerDay/3600)
      }
  }
  
  func editGoal() {
    var goalName: String!
    var timeValue: Int!
    let formValues = self.form.values()

    if let goalValue = formValues["goal"] { // Caution: won't work if nil 
      goalName = goalValue as! String
    } else {
      goalName = goal.name
    }
    
    if let time = formValues["time"] { // Caution: won't work if nil
      timeValue = time as! Int
    } else {
      timeValue = Int(goal.timePerDay/3600)
    }
    
    // create goal
    let editedGoal = Goal(name: goalName, timePerDay: Double(timeValue))
    // remove old goal
    var counter = 0
    for g in goals {
      if ( g.name == goal.name ) { // Caution: really bad to reference by name
        goals.remove(at: counter)
        break
      }
      counter += 1
    }
    goals.append(editedGoal)
  }
  
  @IBAction func doneBtnTapped(_ sender: Any) {
    self.editGoal()
    self.performSegue(withIdentifier: "unwindToGoalsVC", sender: nil)
  }
  @IBAction func cancelBtnTapped(_ sender: Any) { self.dismiss(animated: true, completion: nil) } // dismiss vc
}

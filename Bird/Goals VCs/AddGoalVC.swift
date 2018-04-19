//
//  AddGoalVC.swift
//  Bird
//
//  Created by Arjun Madgavkar on 4/18/18.
//  Copyright © 2018 Arjun Madgavkar. All rights reserved.
//

import UIKit
import Disk
import Eureka

class AddGoalVC: FormViewController {
  var goals = [Goal]()

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.largeTitleDisplayMode = .never // No large title
    setUpForm()
    dataPull()
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
        row.placeholder = "Meditate"
      }
      // Time
      <<< IntRow(){ row in
        row.title = "Hours per Day"
        row.tag = "time"
        row.placeholder = "1"
      }
      // Button
      +++ Section()
      <<< ButtonRow(){ row in
        row.title = "Add Goal 🍾"
        }
        .onCellSelection({ (cell, row) in
          self.addGoal()
        })
  }
  
  func dataPull() {
    // Get data saved on Disk
    do { goals = try Disk.retrieve("goals.json", from: .documents, as: [Goal].self) }
    catch let error { print("\(error)") }
  }
  
  func addGoal() {
    var goal: String!
    var hours: Int
    
    let formValues = self.form.values() // Get form values
    
    if ( formValues["goal"] != nil ) { // Goal
      goal = formValues["goal"] as? String
    } else {
      showAlert(withTitle: "Goal Missing", message: "Please enter the goal that you want to accomplish to continue.")
      return
    }
    if ( formValues["time"] != nil ) { // Time
      hours = formValues["time"] as! Int
    } else {
      showAlert(withTitle: "Time Missing", message: "Please enter the amount of time you want to spend on this goal per day.")
      return
    }
    
    let newGoal = Goal(name: goal, timePerDay: hours) // create goal
    goals.append(newGoal) // add to array
    do { try Disk.save(goals, to: .documents, as: "goals.json") } // try to save to array
    catch let error { print(error) }
    
  }

}














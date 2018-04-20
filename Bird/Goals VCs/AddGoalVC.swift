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
  var categories = [Category]()
  var activities = [String]()
  var delegate: AddGoalDelegate?

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
    do { categories = try Disk.retrieve("categories.json", from: .documents, as: [Category].self) }
    catch let error { print("\(error)") }
    do { activities = try Disk.retrieve("activities.json", from: .documents, as: [String].self) }
    catch let error { print("\(error)") }
    do { goals = try Disk.retrieve("goals.json", from: .documents, as: [Goal].self) }
    catch let error { print("\(error)") }
  }
  
  func addGoal() {
    var goal: String!
    var hours: Double
    
    let formValues = self.form.values() // Get form values
    
    if ( formValues["goal"] != nil ) { // Goal
      goal = formValues["goal"] as? String
    } else {
      showAlert(withTitle: "Goal Missing", message: "Please enter the goal that you want to accomplish to continue.")
      return
    }
    
    var goalExists = false // use this to check whether there is a corresponding activity or category
    for category in categories {
      if ( category.name == goal ) { goalExists = true }
    }
    if ( !goalExists ) { // only if we haven't already found the goal
      for activity in activities {
        if ( activity == goal ) { goalExists = true }
      }
    }
    if ( !goalExists ) {
      showAlert(withTitle: "Error", message: "Your goal name has to be the same as a category or an activity you've created (on your calendar). That way, we can automatically check when your streak increases!")
      return
    }
    
    if ( formValues["time"] != nil ) { // Time
      hours = Double(formValues["time"] as! Int)
    } else {
      showAlert(withTitle: "Time Missing", message: "Please enter the amount of time you want to spend on this goal per day.")
      return
    }
    
    let newGoal = Goal(name: goal, timePerDay: hours) // create goal
    goals.append(newGoal) // add to array
    do { try Disk.save(goals, to: .documents, as: "goals.json") } // try to save to array
    catch let error { print(error) }
    delegate?.didAdd(goal: newGoal) // tell your delegate to do the work to update vc
    
  }

}














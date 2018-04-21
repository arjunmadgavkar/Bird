//
//  AddBlockVC.swift
//  Bird
//
//  Created by Arjun Madgavkar on 3/29/18.
//  Copyright © 2018 Arjun Madgavkar. All rights reserved.
//

import Disk
import UIKit
import Eureka
import ColorPickerRow

class AddBlockVC: FormViewController {
  // Create the delegate here, but set it in YourDayVC
  weak var addBlockDelegate : AddBlockDelegate?
  var shouldPickColor = true
  var timeChanged = false
  var timeBlocks = [TimeBlock]()
  var categories = [Category]()
  var goals = [Goal]()
  var namesOfCategories = [String]()
  var categoriesWithColors = [String]()
  var namesOfColors = [String]()
  var activities = [String]()
  let today = Date()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.largeTitleDisplayMode = .never // No large title
    dataPull() // Get data from disk + add to arrays
    setUpForm() // Set up form with properties
  }
  
  func dataPull() {
    // Get data saved on Disk
    do { timeBlocks = try Disk.retrieve("timeBlocks.json", from: .documents, as: [TimeBlock].self) }
    catch let error { print("\(error)") }
    do { categories = try Disk.retrieve("categories.json", from: .documents, as: [Category].self) }
    catch let error { print("\(error)") }
    do { activities = try Disk.retrieve("activities.json", from: .documents, as: [String].self) }
    catch let error { print("\(error)") }
    do { goals = try Disk.retrieve("goals.json", from: .documents, as: [Goal].self) }
    catch let error { print("\(error)") }
    
    for cat in categories {
      namesOfCategories.append(cat.name)
      namesOfColors.append(cat.color)
      if ( cat.color != "tempColor") {
        categoriesWithColors.append(cat.name)
      }
    }
  }
  
  func setUpForm() {
    let cal = Calendar.current
    var dc = DateComponents()
    var dcChanged = DateComponents()
    var dcEnd = DateComponents()
    // Hour
    let hr = cal.component(.hour, from: today)
    dc.hour = hr
    dcChanged.hour = hr
    dcEnd.hour = hr + 1
    // Minute
    var minute = cal.component(.minute, from: today)
    if ( minute < 15 ) { minute = 0 }
    else if ( minute >= 15 && minute < 30) { minute = 15 }
    else if ( minute >= 30 && minute < 45 ) { minute = 30 }
    else { minute = 45 }
    dc.minute = minute
    dcChanged.minute = minute
    dcEnd.minute = minute

    SuggestionAccessoryRow<String>.defaultCellSetup = { cell, row in
      cell.textLabel?.font = AvenirNext(size: 17.0)
      cell.textField?.font = AvenirNext(size: 17.0)
    }
    TextAreaRow.defaultCellSetup = { cell, row in
      cell.textLabel?.font = AvenirNext(size: 17.0)
      cell.textView?.font = AvenirNext(size: 17.0)
      cell.placeholderLabel?.font = AvenirNext(size: 17.0)
    }
    SwitchRow.defaultCellSetup = { cell, row in
      cell.textLabel?.font = AvenirNext(size: 17.0)
      cell.textLabel?.numberOfLines = 0
    }
    IntRow.defaultCellSetup = { cell, row in
      cell.textLabel?.font = AvenirNext(size: 17.0)
      cell.textLabel?.numberOfLines = 0
      cell.textField?.font = AvenirNext(size: 17.0)
    }
    TimeRow.defaultCellSetup = { cell, row in
      cell.datePicker.minuteInterval = 15
      cell.textLabel?.font = AvenirNext(size: 17.0)
    }
    DateRow.defaultCellSetup = { cell, row in
      cell.textLabel?.font = AvenirNext(size: 17.0)
    }
    ButtonRow.defaultCellSetup = {cell, row in
      cell.textLabel?.font = AvenirNext(size: 20.0)
      cell.textLabel?.textColor = UIColor(rgb: 0x060A78).withAlphaComponent(1.0)
    }
    
    form
      // Category + activity
      +++ Section("Activity & Category")
      <<< SuggestionAccessoryRow<String>() {
        $0.filterFunction = { text in
          self.namesOfCategories.filter({ $0.hasPrefix(text) })
        }
        //        $0.onChange({ row in
        //          self.catColor = row.value
        //        })
        $0.placeholder = "Deep Work"
        $0.title = "Category"
        $0.tag = "category"
      }
      <<< SuggestionAccessoryRow<String>() {
        $0.filterFunction = { text in
          self.activities.filter({ $0.hasPrefix(text) })
        }
        $0.placeholder = "Code 🙏🏽"
        $0.title = "Activity"
        $0.tag = "activity"
      }
      <<< InlineColorPickerRow() { (row) in
        row.hidden = Condition.function(["category"], { form in
          let suggestionRow = form.rowBy(tag: "category")
          if let catName = suggestionRow?.baseValue as? String {
            if ( self.categoriesWithColors.contains(catName) ) {
              self.shouldPickColor = false
              return true
            }
          }
          return false
        })
        row.title = "Color Picker"
        row.tag = "color"
        row.isCircular = false
        row.showsPaletteNames = true
        row.value = UIColor.green
      }
      // Start + end time + date
      +++ Section()
      <<< TimeRow(){ row in
        row.title = "Start Time"
        row.tag = "start_time"
        row.value = cal.date(from: dc)
      }
      <<< TimeRow(){ row in
        row.title = "End Time"
        row.tag = "end_time"
        row.value = cal.date(from: dcEnd)                         // Set original date
        row.hidden = Condition.function(["start_time"], { form in // Set date if other row changes
          let timeRow = form.rowBy(tag: "start_time")
          let dateValue = timeRow?.baseValue as? Date
          var newDateComponents = DateComponents()
          newDateComponents.hour = cal.component(.hour, from: dateValue!) + 1
          newDateComponents.minute = cal.component(.minute, from: dateValue!)
          row.value = cal.date(from: newDateComponents)
          return false
        })
      }
      <<< DateRow(){ row in
        row.title = "Date"
        row.tag = "date"
        row.maximumDate = today
        row.value = today
      }
      // Data
      +++ Section()
      <<< IntRow(){ row in
        row.title = "Rate the quality of the experience (out of 10)"
        row.tag = "rating"
        row.placeholder = "5"
      }
      <<< SwitchRow(){ row in
        row.title = "Did you experience long periods of flow?"
        row.tag = "flow"
        row.value = false
      }
      <<< SwitchRow(){ row in
        row.title = "Did you experience long periods of unpleasant feelings?"
        row.tag = "unpleasant"
        row.value = false
      }
      <<< TextAreaRow(){ row in
        row.title = "What did you accomplish during this time?"
        row.tag = "accomplishments"
        row.placeholder = "What did you accomplish during this time? (optional)"
        row.value = ""
      }
      <<< TextAreaRow(){ row in
        row.title = "What did you learn during this time?"
        row.tag = "learnings"
        row.placeholder = "What did you learn during this time? (optional)"
        row.value = ""
      }
      // Button
      +++ Section()
      <<< ButtonRow(){ row in
        row.title = "⏰ Add Time Block ⏰"
        }
        .onCellSelection({ (cell, row) in
          self.addTimeBlock()
        })
  }
  
  func addTimeBlock() {
    // Form properties
    var color : UIColor?
    var flow, unpleasant : Bool?
    var category, catColor, activity, accomplishments, learnings: String?
    var quality : Int?
    // Date properties
    let calendar = Calendar.current
    var startDateComponents = DateComponents()
    var endDateComponents = DateComponents()
    
    // Get form values
    let formValues = self.form.values()
    if ( formValues["category"] != nil ) { category = formValues["category"] as? String }
    if ( formValues["activity"] != nil ) { activity = formValues["activity"] as? String }
    if ( formValues["color"] != nil ) {
      color = formValues["color"] as? UIColor
      shouldPickColor = false
    }
    if ( formValues["accomplishments"] != nil ) { accomplishments = formValues["accomplishments"] as? String }
    else { accomplishments = "Nothing added by user." }
    if ( formValues["learnings"] != nil ) { learnings = formValues["learnings"] as? String }
    else { learnings = "Nothing added by user." }
    if ( formValues["rating"] != nil ) { quality = formValues["rating"] as? Int }
    // Boolean values
    if ( formValues["flow"] != nil ) { flow = formValues["flow"] as? Bool }
    else { flow = false; }
    if ( formValues["unpleasant"] != nil ) { unpleasant = formValues["unpleasant"] as? Bool }
    else { unpleasant = false; }
    if ( formValues["start_time"] != nil ) {
      let date = formValues["start_time"] as? Date
      startDateComponents.hour = calendar.component(.hour, from: date!)
      startDateComponents.minute = calendar.component(.minute, from: date!)
    }
    if ( formValues["end_time"] != nil ) {
      let date = formValues["end_time"] as? Date
      endDateComponents.hour = calendar.component(.hour, from: date!)
      endDateComponents.minute = calendar.component(.minute, from: date!)
    }
    if ( formValues["date"] != nil ) {
      let date = (formValues["date"] as? Date)!
      startDateComponents.month = calendar.component(.month, from: date)
      startDateComponents.day = calendar.component(.day, from: date)
      startDateComponents.year = calendar.component(.year, from: date)
      startDateComponents.timeZone = calendar.timeZone
      endDateComponents.month = calendar.component(.month, from: date)
      endDateComponents.day = calendar.component(.day, from: date)
      endDateComponents.year = calendar.component(.year, from: date)
      endDateComponents.timeZone = calendar.timeZone
    }
    
    let startDate = calendar.date(from: startDateComponents)
    let endDate = calendar.date(from: endDateComponents)
    
    if ( category != nil && activity != nil && quality != nil && !shouldPickColor ) {
      // Get length of time
      let lengthOfTime = endDate?.minutes(from: startDate!)
      
      // Handle category
      var categoryCounter = 0
      var addCategory = false
      for cat in categories {
        if ( cat.name == category! ) {
          if ( cat.color == "tempColor") {
            // Remove
            categories.remove(at: categoryCounter)
            addCategory = true
            // Set new color
            catColor = (color?.toHex())!
          } else {
            catColor = cat.color
          }
        }
        categoryCounter+=1
      }
      
      let newCategory = Category(name: category!, color: catColor!)
      
      // Create timeBlock
      let timeBlock = TimeBlock(category : newCategory, activity : activity!, startDate : startDate!, endDate : endDate!, lengthOfTime : lengthOfTime!, quality : quality!, flow : flow!, unpleasantFeelings : unpleasant!, accomplishments : accomplishments!, learnings : learnings!)
     
      // Check to see if the time block already exists
      var counter = 0
      for existingBlock in timeBlocks {
        if ( existingBlock.startDate == startDate || existingBlock.endDate == endDate ) {
          self.showAlert(withTitle: "Overwriting", message: "You are overwriting information that exists during this time block.")
          timeBlocks.remove(at: counter)
          break
        }
        counter+=1
      }
      
      // Handle activities
      var addActivity = true
      for a in activities {
        if ( a == activity ) {
          addActivity = false
        }
      }
      
      // Save category + activity
      if ( addCategory ) {
        categories.append(newCategory)
        categories.sort(by: { (c1, c2) -> Bool in
          return c1.name < c2.name
        })
        do { try Disk.save(categories, to: .documents, as: "categories.json") }
        catch let error { print("\(error)") }
      }
      if ( addActivity ) {
        activities.append(activity!)
        do { try Disk.save(activities, to: .documents, as: "activities.json") }
        catch let error { print("\(error)") }
      }
      
      // Check to see if this counts towards a goal
      var goalToUpdate: Goal!
      var goalCount = false
      for goal in goals {
        if ( goal.name == category ) {
          goalCount = true
          goalToUpdate = goal
          break
        }
        if ( goal.name == activity ) {
          goalCount = true
          goalToUpdate = goal
          break
        }
      }
      if ( goalCount ) {
        let amountCompleted = Double((endDate?.timeIntervalSince(startDate!))!) // get duration of timeBlock in seconds
        if ( amountCompleted >= goalToUpdate.timePerDay ) { // check whether user has completed required amount
          goalToUpdate.incrementCompletions(dateCompleted: startDate!)
        } else { // partially complete
          if ( goalToUpdate.getPartiallyComplete() ) { // already started
            goalToUpdate.checkGoalCompleted(newDate: startDate!, amountCompleted: amountCompleted)
          } else {
            goalToUpdate.goalPartiallyComplete(startingDate: startDate!, amountCompleted: amountCompleted)
          }
        }
        do { try Disk.save(goals, to: .documents, as: "goals.json") } // update goals
        catch let error { print("\(error)") }
      }
      
      timeBlocks.append(timeBlock) // add to timeBlocks array
      timeBlocks.sort(by: { (t1, t2) -> Bool in // sort timeBlocks array
        return t1.startDate < t2.startDate
      })
      
      do {
        try Disk.save(timeBlocks, to: .documents, as: "timeBlocks.json") // Save the new timeBlocks
        addBlockDelegate?.didUpdate(timeBlock: timeBlock) // Tell YourDayCollectionVC "something changed, update yourself"
      }
      catch let error { print("\(error)") }
    } else {
      if ( category == nil ) { self.showAlert(withTitle: "Missing Information", message: "Please fill out the category.") }
      else if ( activity == nil ) { self.showAlert(withTitle: "Missing Information", message: "Please fill out the activity.") }
      else if ( quality == nil ) { self.showAlert(withTitle: "Missing Information", message: "Please rate the quality of the experience.") }
      else { self.showAlert(withTitle: "Missing Information", message: "Please pick a color.") }
    }
  } // addTimeBlock()
}

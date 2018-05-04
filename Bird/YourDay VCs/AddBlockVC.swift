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
  var namesOfActivities = [String]()
  var categoriesWithColors = [String]()
  var namesOfColors = [String]()
  var activities = [Activity]()
  let today = Date()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.largeTitleDisplayMode = .never // No large title
    dataPull() // Get data from disk + add to arrays
    setUpForm() // Set up form with properties
  }
  
  func dataPull() {
    // Get data saved on Disk
    do {
      if let blocks = try TimeBlock.getTimeBlocks() {
        timeBlocks = blocks
      }
    } catch {
      print("error")
    }
    
    do { categories = try Disk.retrieve("categories.json", from: .documents, as: [Category].self) }
    catch let error { print("\(error)") }
    do { activities = try Disk.retrieve("activities.json", from: .documents, as: [Activity].self) }
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
    namesOfCategories.sort() // sorted order
    
    for activity in activities {
      namesOfActivities.append(activity.name)
    }
    namesOfActivities.sort() // sorted order
    
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
          self.namesOfActivities.filter({ $0.hasPrefix(text) })
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
        row.title = "Notes"
        row.tag = "notes"
        row.placeholder = "Anything you want to note about this event? (optional)"
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
    var categoryString, catColor, activityString, notes: String?
    var quality : Int?
    // Date properties
    let calendar = Calendar.current
    var startDateComponents = DateComponents()
    var endDateComponents = DateComponents()
    
    // Get form values
    let formValues = self.form.values()
    if ( formValues["category"] != nil ) { categoryString = formValues["category"] as? String }
    if ( formValues["activity"] != nil ) { activityString = formValues["activity"] as? String }
    if ( formValues["color"] != nil ) {
      color = formValues["color"] as? UIColor
      shouldPickColor = false
    }
    if ( formValues["notes"] != nil ) { notes = formValues["notes"] as? String }
    else { notes = "Nothing added." }
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
    
    if startDate! > endDate! { // make sure that the dates are valid
      showAlert(withTitle: "Error", message: "Start date is after the end date. Please adjust data accordingly.")
      return
    }
    
    let duration = endDate?.minutes(from: startDate!)
    let hoursToAdd = Double(duration!/60)
    
    if ( categoryString != nil && activityString != nil && quality != nil && !shouldPickColor ) {
      // Get length of time
      let lengthOfTime = endDate?.minutes(from: startDate!)
      
      // Handle category
      var catty: Category?
      var catCounter = 0
      var addCategory = true
      for cat in categories {
        if ( cat.getName() == categoryString! ) { // category already exists
          catty = cat
          addCategory = false
          if ( cat.getColor() == "tempColor") { // need to update color
            catColor = (color?.toHex())!
            catty?.setColor(color: catColor!) // set the color
            catty?.addToTotalHours(hoursToAdd: hoursToAdd)
          } else {
            catColor = catty?.getColor() // use the already set color
            catty?.addToTotalHours(hoursToAdd: hoursToAdd)
          }
          break
        }
        catCounter += 1
      }
      
      if ( addCategory ) { // category doesn't exist, so add it
        let newCategory = Category(name: categoryString!)
        categories.append(newCategory)
        catty = newCategory
        do { try Disk.save(categories, to: .documents, as: "categories.json") }
        catch let error { print("\(error)") }
      } else {
        categories.remove(at: catCounter)
        categories.append(catty!)
        do { try Disk.save(categories, to: .documents, as: "categories.json") }
        catch let error { print("\(error)") }
      }
      
      // Handle activity
      var acty: Activity?
      var actCounter = 0
      var addActivity = true
      for act in activities {
        if ( act.getName() == activityString! ) { // activity already exists
          acty = act
          addActivity = false
          acty?.addToTotalHours(hoursToAdd: hoursToAdd)
          break
        }
        actCounter += 1
      }
      
      if ( addActivity ) { // activity doesn't exist, so add it
        let newActivity = Activity(name: activityString!)
        activities.append(newActivity)
        acty = newActivity
        do { try Disk.save(activities, to: .documents, as: "activities.json") }
        catch let error { print("\(error)") }
      } else {
        activities.remove(at: actCounter)
        activities.append(acty!)
        do { try Disk.save(activities, to: .documents, as: "activities.json") }
        catch let error { print("\(error)") }
      }
      
      // Create timeBlock
      let timeBlock = TimeBlock(category : catty!, activity : acty!, startDate : startDate!, endDate : endDate!, lengthOfTime : lengthOfTime!, quality : quality!, flow : flow!, unpleasantFeelings : unpleasant!, notes : notes!)
      
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
      
      // Check to see if this counts towards a goal
      var goalToUpdate: Goal!
      var goalCount = false
      for goal in goals {
        if ( goal.name == categoryString ) {
          goalCount = true
          goalToUpdate = goal
          break
        }
        if ( goal.name == activityString ) {
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
      if ( timeBlock.isEarliestTimeBlock() ) { // if it's the earliest timeBlock, then set it
        TimeBlock.setEarliestTimeBlock(timeBlock: timeBlock)
      }
      do {
        try TimeBlock.setTimeBlocks(timeBlocks: timeBlocks) // Save the new timeBlocks
        addBlockDelegate?.didUpdate(timeBlock: timeBlock) // Tell YourDayCollectionVC "something changed, update yourself"
        self.navigationController?.popToRootViewController(animated: true)
      }
      catch {
        print("error")
      }
    } else {
      if ( categoryString == nil ) { self.showAlert(withTitle: "Missing Information", message: "Please fill out the category.") }
      else if ( activityString == nil ) { self.showAlert(withTitle: "Missing Information", message: "Please fill out the activity.") }
      else if ( quality == nil ) { self.showAlert(withTitle: "Missing Information", message: "Please rate the quality of the experience.") }
      else { self.showAlert(withTitle: "Missing Information", message: "Please pick a color.") }
    }
  } // addTimeBlock()
}

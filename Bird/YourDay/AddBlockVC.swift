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
  var category : String?
  var timeBlocks = [TimeBlock]()
  var categories = [Category]()
  var namesOfCategories = [String]()
  var activities = [String]()
  let today = Date()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Get data saved on Disk
    do { timeBlocks = try Disk.retrieve("timeBlocks.json", from: .documents, as: [TimeBlock].self) }
    catch let error { print("\(error)") }
    do { categories = try Disk.retrieve("categories.json", from: .documents, as: [Category].self) }
    catch let error { print("\(error)") }
    do { activities = try Disk.retrieve("activities.json", from: .documents, as: [String].self) }
    catch let error { print("\(error)") }
    
    for cat in categories {
      namesOfCategories.append(cat.name)
    }
    
    // Row properties
    NameRow.defaultCellSetup = { cell, row in
      cell.textLabel?.font = AvenirNext(size: 17.0)
      cell.textField?.font = AvenirNext(size: 17.0)
    }
    TextAreaRow.defaultCellSetup = { cell, row in
      cell.textLabel?.font = AvenirNext(size: 17.0)
      cell.textView?.font = AvenirNext(size: 17.0)
      cell.placeholderLabel?.font = AvenirNext(size: 17.0)
    }
    TextRow.defaultCellSetup = { cell, row in
      cell.textLabel?.font = AvenirNext(size: 17.0)
      cell.textLabel?.numberOfLines = 0
      cell.textField?.font = AvenirNext(size: 17.0)
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
      cell.datePicker.minuteInterval = 15
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
        //if ( categories[category!] == nil ) { row.hidden = true }
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
        let cal = Calendar.current
        var dc = DateComponents()
        dc.hour = cal.component(.hour, from: today)
        var minute = cal.component(.minute, from: today)
        if ( minute < 15 ) { minute = 0 }
        else if ( minute >= 15 && minute < 30) { minute = 15 }
        else if ( minute >= 30 && minute < 45 ) { minute = 30 }
        else { minute = 45 }
        dc.minute = minute
        row.value = cal.date(from: dc)
      }
      <<< TimeRow(){ row in
        row.title = "End Time"
        row.tag = "end_time"
        let cal = Calendar.current
        var dc = DateComponents()
        dc.hour = cal.component(.hour, from: today) + 1
        var minute = cal.component(.minute, from: today)
        if ( minute < 15 ) { minute = 0 }
        else if ( minute >= 15 && minute < 30) { minute = 15 }
        else if ( minute >= 30 && minute < 45 ) { minute = 30 }
        else { minute = 45 }
        dc.minute = minute
        let rowDate = cal.date(from: dc)
        row.value = rowDate
      }
      <<< DateRow(){ row in
        row.title = "Date"
        row.tag = "date"
        let today = Date()
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
    var activity, accomplishments, learnings : String?
    var startTimeHour, startTimeMinute, endTimeHour, endTimeMinute, quality : Int?
    // Date properties
    let calendar = Calendar.current
    var startDateComponents = DateComponents()
    var endDateComponents = DateComponents()
    
    // Get form values
    let formValues = self.form.values()
    // String values
    if ( formValues["category"] != nil ) {
      category = formValues["category"] as? String
    }
    if ( formValues["activity"] != nil ) {
      activity = formValues["activity"] as? String
    }
    if ( formValues["color"] != nil ) {
      color = formValues["color"] as? UIColor
    }
    if ( formValues["accomplishments"] != nil ) {
      accomplishments = formValues["accomplishments"] as? String
    }
    if ( formValues["learnings"] != nil ) {
      learnings = formValues["learnings"] as? String
    } else {
      learnings = formValues["accomplishments"] as? String
    }
    // Int values
    if ( formValues["rating"] != nil ) {
      quality = formValues["rating"] as? Int
    }
    // Boolean values
    if ( formValues["flow"] != nil ) {
      flow = formValues["flow"] as? Bool
    } else {
      flow = false;
    }
    if ( formValues["unpleasant"] != nil ) {
      unpleasant = formValues["unpleasant"] as? Bool
    } else {
      unpleasant = false;
    }
    // Date values
    if ( formValues["start_time"] != nil ) {
      let date = formValues["start_time"] as? Date
      startDateComponents.hour = calendar.component(.hour, from: date!)
      startDateComponents.minute = calendar.component(.minute, from: date!)
    }
    if ( formValues["end_time"] != nil ) {
      let date = formValues["end_time"] as? Date
      endTimeHour = calendar.component(.hour, from: date!)
      endTimeMinute = calendar.component(.minute, from: date!)
      endDateComponents.hour = endTimeHour
      endDateComponents.minute = endTimeMinute
    }
    if ( formValues["date"] != nil ) {
      let date = (formValues["date"] as? Date)!
      // Set up dates
      var localTimeZoneAbbreviation: String { return TimeZone.current.abbreviation() ?? "" }
      startDateComponents.month = calendar.component(.month, from: date)
      startDateComponents.day = calendar.component(.day, from: date)
      startDateComponents.year = calendar.component(.year, from: date)
      startDateComponents.timeZone = TimeZone(abbreviation: localTimeZoneAbbreviation)
      endDateComponents.month = calendar.component(.month, from: date)
      endDateComponents.day = calendar.component(.day, from: date)
      endDateComponents.year = calendar.component(.year, from: date)
      endDateComponents.timeZone = TimeZone(abbreviation: localTimeZoneAbbreviation)
    }
    
    let startDate = calendar.date(from: startDateComponents)
    let endDate = calendar.date(from: endDateComponents)
    
    if ( category != nil && activity != nil && quality != nil && color != nil ) {
      // Get length of time
      let lengthOfTime = endDate?.minutes(from: startDate!)
      
      // Create new category
      let newCategory = Category(name: category!, color: (color?.toHex())!)
      
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
      
      // Add to array and save to Disk
      timeBlocks.append(timeBlock)
      
      // Handle category
      var addCategory = true
      for c in namesOfCategories {
        if ( c == category ) {
          addCategory = false
        }
      }
      
      // Handle activities
      var addActivity = true
      for a in activities {
        if ( a == activity ) {
          addActivity = false
        }
      }
      
      if ( addCategory ) {
        categories.append(newCategory)
        do { try Disk.save(categories, to: .documents, as: "categories.json") }
        catch let error { print("\(error)") }
      }
      if ( addActivity ) {
        activities.append(activity!)
        do { try Disk.save(activities, to: .documents, as: "activities.json") }
        catch let error { print("\(error)") }
      }
      
      do {
        try Disk.save(timeBlocks, to: .documents, as: "timeBlocks.json")
        // Tell YourDayCollectionVC that something changed, so YourDay can update its view
        addBlockDelegate?.didUpdate(timeBlock: timeBlock)
      }
      catch let error { print("\(error)") }
    } else {
      if ( category == nil ) {
        self.showAlert(withTitle: "Missing Information", message: "Please fill out the category.")
      } else if ( activity == nil ) {
        self.showAlert(withTitle: "Missing Information", message: "Please fill out the activity.")
      } else if ( quality == nil ) {
        self.showAlert(withTitle: "Missing Information", message: "Please rate the quality of the experience.")
      } else {
        self.showAlert(withTitle: "Missing Information", message: "Please pick a color.")
      }
    }
  }
  
  
  
  
  
}

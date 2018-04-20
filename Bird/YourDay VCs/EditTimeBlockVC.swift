//
//  EditTimeBlockVC.swift
//  Bird
//
//  Created by Arjun Madgavkar on 4/12/18.
//  Copyright © 2018 Arjun Madgavkar. All rights reserved.
//

import UIKit
import Eureka
import Disk
import ColorPickerRow

class EditTimeBlockVC: FormViewController {
  let today = Date()
  let userCalendar = Calendar.current
  var category, catColor : String?
  var timeBlock: TimeBlock!
  var timeBlocks = [TimeBlock]()
  var categories = [Category]()
  var namesOfCategories = [String]()
  var categoriesWithColors = [String]()
  var namesOfColors = [String]()
  var activities = [String]()
  var shouldPickColor = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    dataPull() // Pull data
    setUpForm() // Set up form
  }
  
  
  func dataPull() {
    // Get data saved on Disk
    do { timeBlocks = try Disk.retrieve("timeBlocks.json", from: .documents, as: [TimeBlock].self) }
    catch let error { print("\(error)") }
    do { categories = try Disk.retrieve("categories.json", from: .documents, as: [Category].self) }
    catch let error { print("\(error)") }
    do { activities = try Disk.retrieve("activities.json", from: .documents, as: [String].self) }
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
    var startTime = DateComponents()
    var endTime = DateComponents()
    startTime.hour = userCalendar.component(.hour, from: timeBlock.startDate) // Hour
    endTime.hour = userCalendar.component(.hour, from: timeBlock.endDate) // Hour
    startTime.minute = userCalendar.component(.minute, from: timeBlock.startDate) // Minute
    endTime.minute = userCalendar.component(.minute, from: timeBlock.endDate) // Minute

    SuggestionAccessoryRow<String>.defaultCellSetup = { cell, row in
      cell.textLabel?.font = AvenirNext(size: 17.0)
      cell.textField.font = AvenirNext(size: 17.0)
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
        $0.value = timeBlock.category.name
        $0.title = "Category"
        $0.tag = "category"
      }
      <<< SuggestionAccessoryRow<String>() {
        $0.filterFunction = { text in
          self.activities.filter({ $0.hasPrefix(text) })
        }
        $0.value = timeBlock.activity
        $0.title = "Activity"
        $0.tag = "activity"
      }
      <<< InlineColorPickerRow() { (row) in
        row.title = "Color Picker"
        row.tag = "color"
        row.isCircular = false
        row.showsPaletteNames = true
        row.value = UIColor.init(hex: timeBlock.category.color)
      }
      // Start + end time + date
      +++ Section()
      <<< TimeRow(){ row in
        row.title = "Start Time"
        row.tag = "start_time"
        row.value = userCalendar.date(from: startTime)
      }
      <<< TimeRow(){ row in
        row.title = "End Time"
        row.tag = "end_time"
        row.value = userCalendar.date(from: endTime)
      }
      <<< DateRow(){ row in
        row.title = "Date"
        row.tag = "date"
        row.value = timeBlock.startDate
      }
      // Data
      +++ Section()
      <<< IntRow(){ row in
        row.title = "Rate the quality of the experience (out of 10)"
        row.tag = "rating"
        row.value = timeBlock.quality
      }
      <<< SwitchRow(){ row in
        row.title = "Did you experience long periods of flow?"
        row.tag = "flow"
        row.value = timeBlock.flow
      }
      <<< SwitchRow(){ row in
        row.title = "Did you experience long periods of unpleasant feelings?"
        row.tag = "unpleasant"
        row.value = timeBlock.unpleasantFeelings
      }
      <<< TextAreaRow(){ row in
        row.title = "What did you accomplish during this time?"
        row.tag = "accomplishments"
        row.placeholder = "What did you accomplish during this time? (optional)"
        row.value = timeBlock.accomplishments
      }
      <<< TextAreaRow(){ row in
        row.title = "What did you learn during this time?"
        row.tag = "learnings"
        row.placeholder = "What did you learn during this time? (optional)"
        row.value = timeBlock.learnings
      }
  }
  
  func editTimeBlock() {
    // Form properties
    var color : UIColor?
    var flow, unpleasant : Bool?
    var activity, accomplishments, learnings : String?
    var quality : Int?
    // Date properties
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
    else { accomplishments = "Nothing added." }
    if ( formValues["learnings"] != nil ) { learnings = formValues["learnings"] as? String }
    else { learnings = "Nothing added." }
    if ( formValues["rating"] != nil ) { quality = formValues["rating"] as? Int } // Int values
    if ( formValues["flow"] != nil ) { flow = formValues["flow"] as? Bool } // Boolean values
    else { flow = false; }
    if ( formValues["unpleasant"] != nil ) { unpleasant = formValues["unpleasant"] as? Bool }
    else { unpleasant = false; }
    if ( formValues["start_time"] != nil ) { // Date values
      let date = formValues["start_time"] as? Date
      startDateComponents.hour = userCalendar.component(.hour, from: date!)
      startDateComponents.minute = userCalendar.component(.minute, from: date!)
    }
    if ( formValues["end_time"] != nil ) {
      let date = formValues["end_time"] as? Date
      endDateComponents.hour = userCalendar.component(.hour, from: date!)
      endDateComponents.minute = userCalendar.component(.minute, from: date!)
    }
    if ( formValues["date"] != nil ) { // Set up dates
      let date = (formValues["date"] as? Date)!
      startDateComponents.month = userCalendar.component(.month, from: date)
      startDateComponents.day = userCalendar.component(.day, from: date)
      startDateComponents.year = userCalendar.component(.year, from: date)
      startDateComponents.timeZone = userCalendar.timeZone
      endDateComponents.month = userCalendar.component(.month, from: date)
      endDateComponents.day = userCalendar.component(.day, from: date)
      endDateComponents.year = userCalendar.component(.year, from: date)
      endDateComponents.timeZone = userCalendar.timeZone
    }
    
    let startDate = userCalendar.date(from: startDateComponents)
    let endDate = userCalendar.date(from: endDateComponents)
    
    if ( category != nil && activity != nil && quality != nil && !shouldPickColor ) {
      let lengthOfTime = endDate?.minutes(from: startDate!)
      var categoryCounter = 0
      var addCategory = false
      for cat in categories { // Handle category
        if ( cat.name == category! ) {
          if ( cat.color == "tempColor") {
            categories.remove(at: categoryCounter) // Remove
            addCategory = true
            catColor = (color?.toHex())! // Set new color
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
          timeBlocks.remove(at: counter)
          break
        }
        counter+=1
      }
      
      // Add to array and save to Disk
      timeBlocks.append(timeBlock)
      
      // Handle activities
      var addActivity = true
      for a in activities {
        if ( a == activity ) {
          addActivity = false
        }
      }
      
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
      
      do {
        try Disk.save(timeBlocks, to: .documents, as: "timeBlocks.json")
        // Tell YourDayCollectionVC that something changed, so YourDay can update its view
        //addBlockDelegate?.didUpdate(timeBlock: timeBlock, newTimeBlocks: timeBlocks)
      }
      catch let error { print("\(error)") }
    } else {
      if ( category == nil ) { self.showAlert(withTitle: "Missing Information", message: "Please fill out the category.") }
      else if ( activity == nil ) { self.showAlert(withTitle: "Missing Information", message: "Please fill out the activity.") }
      else if ( quality == nil ) { self.showAlert(withTitle: "Missing Information", message: "Please rate the quality of the experience.") }
      else { self.showAlert(withTitle: "Missing Information", message: "Please pick a color.") }
    }
  } // editTimeBlock()

  
  @IBAction func cancelBtnTapped(_ sender: Any) { self.dismiss(animated: true, completion: nil) } // Cancel
  @IBAction func doneBtnTapped(_ sender: Any) { // Save edits + unwind
    editTimeBlock()
    self.performSegue(withIdentifier: "unwindToYourDayVC", sender: nil)
  }
  
  
}

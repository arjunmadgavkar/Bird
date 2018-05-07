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
  var catColor : String?
  var timeBlock: TimeBlock!
  var timeBlocks = [TimeBlock]()
  var categories = [Category]()
  var namesOfCategories = [String]()
  var namesOfActivities = [String]()
  var categoriesWithColors = [String]()
  var namesOfColors = [String]()
  var activities = [Activity]()
  var shouldPickColor = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    dataPull() // Pull data
    setUpForm() // Set up form
  }
  
  
  func dataPull() {
    // Get data saved on Disk
    do { timeBlocks = try TimeBlock.getTimeBlocks()! } // if you're editing, then timeblocks exist...
    catch { print("error") }
    do { categories = try Disk.retrieve("categories.json", from: .documents, as: [Category].self) }
    catch let error { print("\(error)") }
    do { activities = try Disk.retrieve("activities.json", from: .documents, as: [Activity].self) }
    catch let error { print("\(error)") }
    
    for cat in categories {
      namesOfCategories.append(cat.name)
      namesOfColors.append(cat.color)
      if ( cat.color != "tempColor") {
        categoriesWithColors.append(cat.name)
      }
    }
    for act in activities {
      namesOfActivities.append(act.name)
    }
    
  }
  
  func setUpForm() {
    var startTime = DateComponents()
    var endTime = DateComponents()
    // Start Time
    startTime.hour = userCalendar.component(.hour, from: timeBlock.startDate)
    startTime.minute = userCalendar.component(.minute, from: timeBlock.startDate)
    // End Time
    endTime.hour = userCalendar.component(.hour, from: timeBlock.endDate) 
    endTime.minute = userCalendar.component(.minute, from: timeBlock.endDate)

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
      cell.textLabel?.font = AvenirNextHeavy(size: 20.0)
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
          self.namesOfActivities.filter({ $0.hasPrefix(text) })
        }
        $0.value = timeBlock.activity.name
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
        row.title = "Notes"
        row.tag = "notes"
        row.placeholder = "Any notes about this event? (optional)"
        row.value = timeBlock.notes
      }
      // Button
      +++ Section()
      <<< ButtonRow(){ row in
          row.title = "Delete Time Block"
        }
        .onCellSelection({ (cell, row) in
          self.deleteTimeBlock()
        })
        .cellUpdate({ (cell, row) in
          cell.textLabel?.textColor = imagineRed()
        })
  }
  
  func editTimeBlock() {
    // Form properties
    var color : UIColor?
    var flow, unpleasant : Bool?
    var categoryString, activityString, notes : String?
    var quality : Int?
    // Date properties
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
    let newDuration = endDate?.minutes(from: startDate!)
    let newHoursToAdd = Double(newDuration!/60)
    
    if ( categoryString != nil && activityString != nil && quality != nil && !shouldPickColor ) {
      let lengthOfTime = endDate?.minutes(from: startDate!)
      // Handle category
      var catty: Category?
      if ( timeBlock.category.name == categoryString ) { // user didn't change the overall category
        catty = timeBlock.category
        if ( startDate != timeBlock.startDate || endDate != timeBlock.endDate ) { // if the duration is different
          let oldDuration = timeBlock.endDate.minutes(from: timeBlock.startDate)
          let oldHoursToAdd = Double(oldDuration/60)
          let difference = Double(newHoursToAdd-oldHoursToAdd)
          catty?.addToTotalHours(hoursToAdd: difference)
        }
        catColor = (color?.toHex())!
        catty?.setColor(color: catColor!) // set the color
      } else { // they totally changed the category
        for cat in categories {
          if ( cat.getName() == categoryString ) { // category already exists elsewhere, so add to the right one
            catty = cat
            catty?.addToTotalHours(hoursToAdd: newHoursToAdd)
            break
          } else { // totally new category
            catty = Category(name: categoryString!, hoursToAdd: newHoursToAdd)
            categories.append(catty!)
          }
        }
      }
      do { try Disk.save(categories, to: .documents, as: "categories.json") }
      catch let error { print("\(error)") }
      
      // Handle activities
      var acty: Activity?
      if ( timeBlock.activity.name == activityString ) { // same activity
        acty = timeBlock.activity
        if ( startDate != timeBlock.startDate || endDate != timeBlock.endDate ) { // if the duration is different
            let oldDuration = timeBlock.endDate.minutes(from: timeBlock.startDate)
            let oldHoursToAdd = Double(oldDuration/60)
            let difference = Double(newHoursToAdd-oldHoursToAdd)
            acty?.addToTotalHours(hoursToAdd: difference)
        }
      } else { // changed activity
        for act in activities {
          if ( act.getName() == activityString ) { // activity already exists
            acty = act
            acty?.addToTotalHours(hoursToAdd: newHoursToAdd)
            break
          } else { // totally new activity
            acty = Activity(name: activityString!, hoursToAdd: newHoursToAdd)
            activities.append(acty!)
          }
        }
      }
      
      do { try Disk.save(activities, to: .documents, as: "activities.json") }
      catch let error { print("\(error)") }
      
      var counter = 0
      for oldBlock in timeBlocks {
        if ( oldBlock.startDate == timeBlock.startDate ) { // remove the old timeBlock so we can add the edited one
          timeBlocks.remove(at: counter)
          break
        }
        counter += 1
      }
      
      // Edit timeBlock
      timeBlock.category = catty!
      timeBlock.activity = acty!
      timeBlock.startDate = startDate!
      timeBlock.endDate = endDate!
      timeBlock.lengthOfTime = lengthOfTime!
      timeBlock.quality = quality!
      timeBlock.flow = flow!
      timeBlock.unpleasantFeelings = unpleasant!
      timeBlock.notes = notes!
      // add it back to the array
      timeBlocks.append(timeBlock)
      
      do { try TimeBlock.setTimeBlocks(timeBlocks: timeBlocks) }
      catch let error { print("\(error)") }
      
    } else {
      if ( categoryString == nil ) { self.showAlert(withTitle: "Missing Information", message: "Please fill out the category.") }
      else if ( activityString == nil ) { self.showAlert(withTitle: "Missing Information", message: "Please fill out the activity.") }
      else if ( quality == nil ) { self.showAlert(withTitle: "Missing Information", message: "Please rate the quality of the experience.") }
      else { self.showAlert(withTitle: "Missing Information", message: "Please pick a color.") }
    }
  } // editTimeBlock()
  
  func deleteTimeBlock() {
    // Remove timeBlock from array
    var counter = 0
    for oldBlock in timeBlocks {
      if ( oldBlock.startDate == timeBlock.startDate ) {
        timeBlocks.remove(at: counter)
        break
      }
      counter += 1
    }
    // Save the new array of timeBlocks
    do { try TimeBlock.setTimeBlocks(timeBlocks: timeBlocks) }
    catch { print("error") }
    // Dismiss VC
    self.performSegue(withIdentifier: "unwindToYourDayVC", sender: nil)
  }

  // MARK: IBActions
  @IBAction func cancelBtnTapped(_ sender: Any) { self.dismiss(animated: true, completion: nil) } // Cancel
  @IBAction func doneBtnTapped(_ sender: Any) { // Save edits + unwind
    editTimeBlock()
    self.performSegue(withIdentifier: "unwindToYourDayVC", sender: nil)
  }
  
  
}

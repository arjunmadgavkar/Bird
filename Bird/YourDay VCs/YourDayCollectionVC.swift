//
//  YourDayCollectionVC.swift
//  Bird
//
//  Created by Arjun Madgavkar on 3/29/18.
//  Copyright © 2018 Arjun Madgavkar. All rights reserved.
//

import UIKit
import Disk
import JTAppleCalendar

// Adhere to AddBlockDelegate bc AddBlockVC tells us something and we do it for him
class YourDayCollectionVC: UIViewController {
  // Calendar Properties
  let calendar = Calendar.current
  let formatter : DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = Calendar.current.timeZone
    dateFormatter.locale = Calendar.current.locale
    dateFormatter.dateFormat = "MM dd yyyy"
    return dateFormatter
  }()
  let today : DateComponents = {
    var dc = DateComponents()
    dc.month = Calendar.current.component(.month, from: Date())
    dc.day = Calendar.current.component(.day, from: Date())
    dc.year = Calendar.current.component(.year, from: Date())
    return dc
  }()
  var todayDate = Date()
  var currentSelectedCell = CalendarCell()
  var selectedTimeBlock: TimeBlock?
  var timeBlocks = [TimeBlock]()
  var currentDateBlocks = [TimeBlock]()
  fileprivate let sectionInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
  fileprivate let itemsPerRow: CGFloat = 1
  // Outlets
  @IBOutlet weak var timeBlockCollectionView: UICollectionView!
  @IBOutlet weak var calendarCollectionView: JTAppleCalendarView!
  

  override func viewDidLoad() {
    super.viewDidLoad()
    viewControllerSetUp()
    calendarPropertiesSetUp()
    collectionViewSetUp()
  }
  
  // MARK: VC Set Up
  func viewControllerSetUp() {
    self.title = "Your Day"
    self.navigationController?.navigationBar.prefersLargeTitles = true
    self.navigationController?.navigationBar.largeTitleTextAttributes = [
      NSAttributedStringKey.foregroundColor: UIColor.black,
      NSAttributedStringKey.font: AvenirNextHeavy(size: 40.0)
    ]
    // Set Image
    var image = UIImage(named: "add_button")
    image = image?.withRenderingMode(.alwaysOriginal)
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style:.plain, target: self, action: #selector(addBtnClicked))
    // Get rid of back button on next screen
    let backItem = UIBarButtonItem()
    backItem.title = ""
    navigationItem.backBarButtonItem = backItem
  }
  
  // MARK: Calendar Properties Set Up
  func calendarPropertiesSetUp() {
    todayDate = calendar.date(from: today)!
    calendarCollectionView.selectDates([todayDate]) // select today's date right off the bat
    calendarCollectionView.scrollToDate(todayDate, animateScroll: false) // scroll to today's date
    calendarCollectionView.scrollingMode = .stopAtEachSection
    calendarCollectionView.allowsMultipleSelection = false
    calendarCollectionView.minimumLineSpacing = 0 
    calendarCollectionView.minimumInteritemSpacing = 0
  }
  
  // MARK: Time Block CollectionView Set Up
  func collectionViewSetUp() {
    timeBlockCollectionView.delegate = self
    timeBlockCollectionView.dataSource = self
    getBlocksFromDisk()
  }
  
  func getBlocksFromDisk() {
    do { timeBlocks = try Disk.retrieve("timeBlocks.json", from: .documents, as: [TimeBlock].self) }
    catch let error { print("\(error)") }
    for timeBlock in timeBlocks { // Find the timeBlocks that are on today's date
      let userDate = calendar.dateComponents(in: Calendar.current.timeZone, from: timeBlock.startDate)
      if ( userDate.month == today.month && userDate.day == today.day && userDate.year == today.year ) {
        currentDateBlocks.append(timeBlock) // Add them to today's date blocks array
      }
    }
    currentDateBlocks.sort { (t1, t2) -> Bool in
      if ( t1.startDate < t2.startDate ) { return true } // Sort today's blocks by time
      return false
    }
  }
  
  // MARK: Calendar Set Up 
  func configureCell(cell: JTAppleCell?, cellState: CellState) {
    guard let calendarCell = cell as? CalendarCell else { return }
    handleCellTextColor(cell: calendarCell, cellState: cellState)
  }
  
  func handleCellTextColor(cell: CalendarCell, cellState: CellState) {
    if ( cellState.date > todayDate ) { // Gray if it's in the future
      cell.calendarCellLabel?.textColor = UIColor.gray
      cell.selectedView.isHidden = true
    } else {
      if ( cellState.isSelected ) { // If selected
        cell.calendarCellLabel?.textColor = UIColor.white
        cell.selectedView.isHidden = false
      } else { // If not selected
        cell.calendarCellLabel?.textColor = UIColor.black
        cell.selectedView.isHidden = true
      }
    }
  }
  
  // CollectionView changes with calendar
  func newDateSelected(date: Date) {
    currentDateBlocks.removeAll()
    let selectedDate : DateComponents = {
      var selectedDC = DateComponents()
      selectedDC.month = Calendar.current.component(.month, from: date)
      selectedDC.day = Calendar.current.component(.day, from: date)
      selectedDC.year = Calendar.current.component(.year, from: date)
      return selectedDC
    }()
    for timeBlock in timeBlocks {
      let userDate = calendar.dateComponents(in: Calendar.current.timeZone, from: timeBlock.startDate)
      if ( userDate.month == selectedDate.month && userDate.day == selectedDate.day && userDate.year == selectedDate.year ) {
        currentDateBlocks.append(timeBlock) // Add them to today's date blocks array
      }
    }
    timeBlockCollectionView.reloadData()
  }
  
  func didEdit() {
    currentDateBlocks.removeAll()
    getBlocksFromDisk()
    timeBlockCollectionView.reloadData()
  }
  
  @objc func addBtnClicked() {
    performSegue(withIdentifier: "goToAddBlock", sender: nil)
  }
  
  // MARK: Prepare for segue
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if ( segue.identifier == "goToAddBlock" ) { // Tell addBlockVC that THIS VC is its delegate
      if let addBlockVC = segue.destination as? AddBlockVC { // Set the addBlockVC's delegate to YourDayVC
        addBlockVC.addBlockDelegate = self as YourDayCollectionVC
      }
    }
    if ( segue.identifier == "goToDetail" ) {
      if let cell = sender as? UICollectionViewCell,
        let indexPath = self.timeBlockCollectionView?.indexPath(for: cell) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        let vc = segue.destination as! TimeBlockDetailVC
        vc.timeBlock = currentDateBlocks[indexPath.row]
      }
    }
  }
  
  // MARK: Unwind segue
  @IBAction func unwindToYourDay(segue: UIStoryboardSegue) {
    if let _ = segue.source as? EditTimeBlockVC {
      didEdit()
    }
  }
  
}

// MARK: - AddBlockDelegate
extension YourDayCollectionVC: AddBlockDelegate {
  func didUpdate(timeBlock: TimeBlock) {
    currentDateBlocks.removeAll() // clear current date blocks
    getBlocksFromDisk() // get new blocks + current date blocks
    self.timeBlockCollectionView?.reloadData() // Update VC
  }
}

// MARK: - UICollectionViewDataSource
extension YourDayCollectionVC: UICollectionViewDataSource {
  // Number of sections
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  // Number of cells
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return currentDateBlocks.count
  }
  // Data for each cell
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let timeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "timeCell", for: indexPath) as! YourDayCollectionViewCell
    
    // Activity label
    let timeBlock = currentDateBlocks[indexPath.row]
    timeCell.categoryActivityLabel.numberOfLines = 0
    timeCell.categoryActivityLabel.text = timeBlock.category.name + " (" + timeBlock.activity + ")"
    
    // Time label
    var startTime, endTime: String!
    var startTimeMorning, startTimePM, endTimeMorning, endTimePM: Bool!
    let userStartDate = calendar.dateComponents(in: Calendar.current.timeZone, from: timeBlock.startDate)
    let userEndDate = calendar.dateComponents(in: calendar.timeZone, from: timeBlock.endDate)
    
    // Format minutes
    var startMinute = String(describing: userStartDate.minute!)
    if ( startMinute == "0" ) { startMinute = "" }
    else { startMinute = ":" + startMinute }
    var endMinute = String(describing: userStartDate.minute!)
    if ( endMinute == "0" ) { endMinute = "" }
    else { endMinute = ":" + endMinute }
    
    // Format hours
    var startHour = userStartDate.hour!
    if ( startHour == 0 ) { // midnight
      startHour = startHour + 12
      startTimeMorning = true
      startTimePM = false
    } else if ( startHour > 0 && startHour < 12)  { // morning
      startTimeMorning = true
      startTimePM = false
    } else if ( startHour >= 12 ) { // afternoon and evening
      if ( startHour != 12 ) { startHour = startHour - 12 } // don't subtract 12 if it's noon
      startTimeMorning = false
      startTimePM = true
    }
    var endHour = userEndDate.hour!
    if ( endHour == 0 ) { // midnight
      endHour = endHour + 12
      endTimeMorning = true
      endTimePM = false
    } else if ( endHour > 0 && endHour < 12 ) { // morning
      endTimeMorning = true
      endTimePM = false
    } else if ( endHour >= 12 ) { // afternoon and evening
      if ( endHour != 12 ) { endHour = endHour - 12 } // don't subtract 12 if it's noon
      endTimeMorning = false
      endTimePM = true
    }
    
    if ( startTimeMorning && endTimeMorning ) { // both am
      startTime = "\(startHour)" + "\(startMinute)"
      endTime = "\(endHour)" + "\(endMinute)" + "am"
    } else if ( startTimePM && endTimePM ) { // both pm
      startTime = "\(startHour)" + "\(startMinute)"
      endTime = "\(endHour)" + "\(endMinute)" + "pm"
    } else { // different
      startTime = "\(startHour)" + "\(startMinute)" + "am"
      endTime = "\(endHour)" + "\(endMinute)" + "pm"
    }
    
    timeCell.timeLabel.text = startTime + "-" + endTime + ":"
    
    // Set colors
    timeCell.backgroundColor = UIColor(hex: timeBlock.category.color)
    timeCell.layer.borderColor = UIColor.black.cgColor
    timeCell.layer.borderWidth = 2
    
    return timeCell
  }
  
  
}
extension YourDayCollectionVC : UICollectionViewDelegate {
  // Don't need anything
  
}

// MARK: - UICollectionViewDelegateFlowLayout
extension YourDayCollectionVC : UICollectionViewDelegateFlowLayout {
  // This function sets the size of a cell
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
  
    let widthPerItem = view.frame.width // Each item gets the full width of frame
    
    // Calculate height of cell
    let collectionViewHeight = (self.timeBlockCollectionView?.frame.height)! * 2     // Height of CV
    let smallBlock = (collectionViewHeight/24)/4                            // Divide into 15 minute blocks
    let numberOfBlocks = (currentDateBlocks[indexPath.row].lengthOfTime)/15 // Get minutes and divide by 15
    let sizeOfBlock = CGFloat(numberOfBlocks) * smallBlock                  // Multiply by size of 15 minute blocks
    
    return CGSize(width: widthPerItem, height: sizeOfBlock)
  }
  // This function determines the insets (which are all 0) for each section
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return sectionInsets
  }
  // This function determines the spacing between rows
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0.0
  }
  // This function determines the spacing between items
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0.0
  }
  
}

extension YourDayCollectionVC: JTAppleCalendarViewDataSource {
  func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
    let startDate = formatter.date(from: "03 09 2018")
    let params = ConfigurationParameters(startDate: startDate!,
                                         endDate: Date(),
                                         numberOfRows: 1,
                                         generateInDates: .forFirstMonthOnly,
                                         generateOutDates: .off,
                                         hasStrictBoundaries: false)
    return params
  }
  
}

extension YourDayCollectionVC: JTAppleCalendarViewDelegate {
  /*
   
   * CollectionView requests content for cell that is going to be displayed soon (the cell is about to enter the visible field).
   * The cell is either created for the first time
   
  */
  func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
    let calendarCell = calendar.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as! CalendarCell // Gets a calCell object
    calendarCell.calendarCellLabel.text = cellState.text // Since the calCell object is empty, we need to give it text
    configureCell(cell: calendarCell, cellState: cellState) // Configure remaining cell properties
    return calendarCell
  }
  
  // (2) CollectionView is requesting to display the cell after it has its view ready (the cell just became visible).
  func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
    let calendarCell = cell as! CalendarCell
    calendarCell.calendarCellLabel.text = cellState.text
    configureCell(cell: calendarCell, cellState: cellState) // Configure the cell properties
  }
  
  /* Cell Selection */
  func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
    guard let calendarCell = cell as? CalendarCell else { return }
    configureCell(cell: calendarCell, cellState: cellState) // Configure the cell properties
    newDateSelected(date: date) // Show data from particular date
  }
  
  /* Cell Selection from Future Dates */
  func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
    if ( cellState.date > todayDate ) { return false } // If the date is in the future, it cannot be selected
    else { return true } // Otherwise, allow selection
  }
  
  /* Cell De-selection */
  func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
    guard let calendarCell = cell as? CalendarCell else { return }
    configureCell(cell: calendarCell, cellState: cellState) // Configure the cell properties
  }
  
  /* Next 2 functions set up header */
  func calendar(_ calendar: JTAppleCalendarView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTAppleCollectionReusableView {
    let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "header", for: indexPath) as! CalendarHeaderView
    return header
  }
  // Month size?
  func calendarSizeForMonths(_ calendar: JTAppleCalendarView?) -> MonthSize? {
    return MonthSize(defaultSize: 50)
  }
  
}










//
//  YourDayCollectionVC.swift
//  Bird
//
//  Created by Arjun Madgavkar on 3/29/18.
//  Copyright © 2018 Arjun Madgavkar. All rights reserved.
//

import UIKit
import Disk

// Adhere to AddBlockDelegate bc AddBlockVC tells us something and we do it for him
class YourDayCollectionVC: UICollectionViewController, AddBlockDelegate {
  let calendar = Calendar.current
  var timeBlocks = [TimeBlock]()
  var currentDateBlocks = [TimeBlock]()
  fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
  fileprivate let itemsPerRow: CGFloat = 1

  override func viewDidLoad() {
    super.viewDidLoad()
    
    do { timeBlocks = try Disk.retrieve("timeBlocks.json", from: .documents, as: [TimeBlock].self) }
    catch let error { print("\(error)") }
    // Load up collectionView
    for timeBlock in timeBlocks {
      let userDate = calendar.dateComponents(in: Calendar.current.timeZone, from: timeBlock.startDate)
      // Compare with today's date
      var today = DateComponents()
      today.month = calendar.component(.month, from: Date())
      today.day = calendar.component(.day, from: Date())
      today.year = calendar.component(.year, from: Date())
      // If they added to today's calendar
      if ( userDate.month == today.month && userDate.day == today.day && userDate.year == today.year ) {
        // Update set array
        currentDateBlocks.append(timeBlock)
      }
    }
    
    // Organize by time
    currentDateBlocks.sort { (t1, t2) -> Bool in
      if ( t1.startDate < t2.startDate ) {
        return true
      }
      return false
    }
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Tell addBlockVC that THIS VC is its delegate
    if ( segue.identifier == "goToAddBlock" ) {
      if let addBlockVC = segue.destination as? AddBlockVC {
        // Set the addBlockVC's delegate to YourDayVC
        addBlockVC.addBlockDelegate = self as YourDayCollectionVC
      }
    }
  }
  
  // MARK: Protocol
  func didUpdate(timeBlock: TimeBlock) {
    // Get the newly added date
    let userDate = calendar.dateComponents(in: Calendar.current.timeZone, from: timeBlock.startDate)
    // Compare with today's date
    var today = DateComponents()
    today.month = calendar.component(.month, from: Date())
    today.day = calendar.component(.day, from: Date())
    today.year = calendar.component(.year, from: Date())
    // If they added to today's calendar
    if ( userDate.month == today.month && userDate.day == today.day && userDate.year == today.year ) {
      // Update VC
      print("Tina: Date added today!")
      //self.collectionView?.reloadData()
    }
  }
}
// MARK: - UICollectionViewDataSource
extension YourDayCollectionVC {
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return currentDateBlocks.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "timeCell", for: indexPath) as! YourDayCollectionViewCell
    
    // Activity label
    let timeBlock = currentDateBlocks[indexPath.row]
    cell.categoryActivityLabel.text = timeBlock.category + " (" + timeBlock.activity + ")"
    
    // Time label
    let userStartDate = calendar.dateComponents(in: Calendar.current.timeZone, from: timeBlock.startDate)
    let startTime = String(describing: userStartDate.hour!) + ":" + String(describing: userStartDate.minute!)
    let userEndDate = calendar.dateComponents(in: Calendar.current.timeZone, from: timeBlock.endDate)
    let endTime = String(describing: userEndDate.hour!) + ":" + String(describing: userEndDate.minute!)
    cell.timeLabel.text = startTime + "-" + endTime
    
    // Set color
    
    cell.backgroundColor = UIColor.white
    
    return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    // Handled in the segue...
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension YourDayCollectionVC : UICollectionViewDelegateFlowLayout {
  // This function sets the size of a cell
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    // Calculate size of cell
    let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
    let availableWidth = view.frame.width - paddingSpace
    let widthPerItem = availableWidth / itemsPerRow
    
    // Calculate height of cell
    let collectionViewHeight = (self.collectionView?.frame.height)! * 2     // Height of CV
    let smallBlock = (collectionViewHeight/24)/4                            // Divide into 15 minute blocks
    let numberOfBlocks = (currentDateBlocks[indexPath.row].lengthOfTime)/15 // Get minutes and divide by 15
    let sizeOfBlock = CGFloat(numberOfBlocks) * smallBlock                  // Multiply by size of 15 minute blocks
    
    return CGSize(width: widthPerItem, height: sizeOfBlock)
  }
  
  //3
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return sectionInsets
  }
  
  // 4
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return sectionInsets.left
  }
  
  
  
}










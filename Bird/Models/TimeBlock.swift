//
//  TimeBlock.swift
//  Bird
//
//  Created by Arjun Madgavkar on 4/4/18.
//  Copyright © 2018 Arjun Madgavkar. All rights reserved.
//
import UIKit
import Disk
import Eureka
import Foundation

class TimeBlock: Codable, Comparable {
  // Type properties
  static var allTimeBlocks = [TimeBlock]()
  static var earliestTimeBlock: TimeBlock?
  // Instance properties
  var category: Category
  var activity: Activity
  var startDate: Date
  var endDate: Date
  var lengthOfTime: Int
  var quality: Int
  var flow: Bool
  var unpleasantFeelings: Bool
  var notes: String
  
  // Type Methods
  class func getEarliestTimeBlock() -> TimeBlock {
    return self.earliestTimeBlock!
  }
  class func setEarliestTimeBlock(timeBlock: TimeBlock) {
    self.earliestTimeBlock = timeBlock
  }
  
  class func getTimeBlocks() throws -> [TimeBlock]? {
    do {
      let timeBlocks = try Disk.retrieve("timeBlocks.json", from: .documents, as: [TimeBlock].self)
      return timeBlocks
    } catch let error {
      print("Could not get time blocks because of this error: \(error)")
      return nil
    }
  }
  class func setTimeBlocks(timeBlocks: [TimeBlock]) throws {
    self.allTimeBlocks = timeBlocks
    do { try Disk.save(self.allTimeBlocks, to: .documents, as: "timeBlocks.json") } // save to disk
    catch let error { print("\(error)") }
  }
  
  class func deleteAllTimeBlocks() {
    do { try Disk.remove("timeBlocks.json", from: .documents) }
    catch let error { print("\(error)") }
    do { try Disk.remove("earliestTimeBlock.json", from: .documents) }
    catch let error { print("\(error)") }
    self.allTimeBlocks = []
  }
  /* Helpful for debugging crashes*/
  class func deleteMostRecentTimeBlock() throws {
    do {
      if let blocks = try self.getTimeBlocks() {
        var timeBlocks = blocks
        timeBlocks.removeLast()
        try self.setTimeBlocks(timeBlocks: timeBlocks)
      }
    } catch let error {
      print("Could not get time blocks because of this error: \(error)")
    }
  }
    
  final class func < (lhs: TimeBlock, rhs: TimeBlock) -> Bool { // final class, so can't be overridden
    return lhs.startDate < rhs.startDate
  }
  final class func == (lhs: TimeBlock, rhs: TimeBlock) -> Bool { // final class, so can't be overridden
    return lhs.startDate == rhs.startDate
  }
  
  // Instance Methods
  init(category: Category, activity: Activity, startDate: Date, endDate: Date, lengthOfTime: Int, quality: Int, flow: Bool, unpleasantFeelings: Bool, notes: String) {
    self.category = category
    self.activity = activity
    self.startDate = startDate
    self.endDate = endDate
    self.lengthOfTime = lengthOfTime
    self.quality = quality
    self.flow = flow
    self.unpleasantFeelings = unpleasantFeelings
    self.notes = notes
  }
  
  func isEarliestTimeBlock() -> Bool {
    if ( TimeBlock.earliestTimeBlock == nil ) {
      TimeBlock.setEarliestTimeBlock(timeBlock: self)
    } else {
      let currentEarliestTimeBlock = TimeBlock.getEarliestTimeBlock()
      if ( (currentEarliestTimeBlock.startDate) < self.startDate ) {
        return false
      }
    }
    return true
  }
  
  
  
  
  

  
  
  
  
  
  
  
}

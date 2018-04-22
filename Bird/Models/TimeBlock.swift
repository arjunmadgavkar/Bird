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
  var accomplishments: String
  var learnings: String
  
  // Type Methods
  class func getEarliestTimeBlock() -> TimeBlock {
    return self.earliestTimeBlock!
  }
  class func setEarliestTimeBlock(timeBlock: TimeBlock) {
    self.earliestTimeBlock = timeBlock
  }
  final class func < (lhs: TimeBlock, rhs: TimeBlock) -> Bool {
    return lhs.startDate < rhs.startDate
  }
  final class func == (lhs: TimeBlock, rhs: TimeBlock) -> Bool {
    return lhs.startDate == rhs.startDate
  }
  
  // Instance Methods
  init(category: Category, activity: Activity, startDate: Date, endDate: Date, lengthOfTime: Int, quality: Int, flow: Bool, unpleasantFeelings: Bool, accomplishments: String, learnings: String) {
    self.category = category
    self.activity = activity
    self.startDate = startDate
    self.endDate = endDate
    self.lengthOfTime = lengthOfTime
    self.quality = quality
    self.flow = flow
    self.unpleasantFeelings = unpleasantFeelings
    self.accomplishments = accomplishments
    self.learnings = learnings
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

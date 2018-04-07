//
//  TimeBlock.swift
//  Bird
//
//  Created by Arjun Madgavkar on 4/4/18.
//  Copyright © 2018 Arjun Madgavkar. All rights reserved.
//
import UIKit
import Eureka
import Foundation

class TimeBlock : Codable {
  let category : String
  let activity : String
  //let color : String
  let startDate : Date
  let endDate : Date
  let lengthOfTime : Int
  let quality : Int
  let flow : Bool
  let unpleasantFeelings : Bool
  let accomplishments : String
  let learnings : String
  
  init(category : String, activity : String, startDate : Date, endDate : Date, lengthOfTime : Int, quality : Int, flow : Bool, unpleasantFeelings : Bool, accomplishments : String, learnings : String) {
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

  
  
  
  
  
  
  
}

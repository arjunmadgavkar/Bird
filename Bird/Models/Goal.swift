//
//  Goal.swift
//  Bird
//
//  Created by Arjun Madgavkar on 4/18/18.
//  Copyright © 2018 Arjun Madgavkar. All rights reserved.
//

import UIKit

class Goal: Codable { 
  let name: String
  var count: Int
  var timePerDay: Int
  
  init(name: String, timePerDay: Int) {
    self.name = name
    self.count = 0
    self.timePerDay = timePerDay
  }
  
  func incrementCount() {
    self.count += 1
  }
  
  func editTimePerDay(newTimePerDay: Int) {
    self.timePerDay = newTimePerDay
  }
  
  
}

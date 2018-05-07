//
//  Activity.swift
//  Bird
//
//  Created by Arjun Madgavkar on 4/5/18.
//  Copyright © 2018 Arjun Madgavkar. All rights reserved.
//

import UIKit
import Eureka
import Foundation

class Activity: Codable, Comparable, SuggestionValue {
  let name: String
  var totalHours: Double
  
  // Type Methods
  final class func < (lhs: Activity, rhs: Activity) -> Bool {
    return lhs.name < rhs.name
  }
  final class func == (lhs: Activity, rhs: Activity) -> Bool {
    return lhs.name == rhs.name && lhs.totalHours == rhs.totalHours
  }
  
  // Instance Methods
  required init?(string stringValue: String) { // for suggestionValue protocol
    return nil
  }
  
  init(name: String) {
    self.name = name
    self.totalHours = 0
  }
  
  init(name: String, hoursToAdd: Double) {
    self.name = name
    self.totalHours = hoursToAdd
  }
  
  func getName() -> String {
    return self.name
  }
  
  func getTotalHours() -> Double {
    return self.totalHours
  }
  func addToTotalHours(hoursToAdd: Double) {
    self.totalHours += hoursToAdd
  }
  
  var suggestionString: String {
    return "\(self.name)"
  }
  
}

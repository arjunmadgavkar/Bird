//
//  Category.swift
//  Bird
//
//  Created by Arjun Madgavkar on 4/5/18.
//  Copyright © 2018 Arjun Madgavkar. All rights reserved.
//

import UIKit
import Eureka
import Foundation

class Category: Codable, Comparable, SuggestionValue {
  // Type Properties
  
  // Instance Properties
  let name: String
  var color: String
  var totalHours: Double
  
  // Type Methods
  final class func < (lhs: Category, rhs: Category) -> Bool {
    return lhs.name < rhs.name
  }
  final class func == (lhs: Category, rhs: Category) -> Bool {
    return lhs.name == rhs.name && lhs.totalHours == rhs.totalHours
  }
  
  // Instance Methods
  required init?(string stringValue: String) { // for suggestionValue protocol
    return nil
  }
  
  init(name: String) {
    self.name = name
    self.color = "tempColor" // when initializing categories in app delegate for first time, add temporary color
    self.totalHours = 0.0
  }
  
  init(name: String, hoursToAdd: Double) {
    self.name = name
    self.color = "tempColor" // when initializing categories in app delegate for first time, add temporary color
    self.totalHours = hoursToAdd
  }
  
  var suggestionString: String {
    return "\(self.name)"
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
  func getColor() -> String {
    return self.color
  }
  func setColor(color: String) {
    self.color = color
  }
  
}

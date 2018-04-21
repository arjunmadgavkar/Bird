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

class Category: Codable, SuggestionValue {
  let name: String
  var color: String
  var totalHours: Double
  
  
  required init?(string stringValue: String) { // for suggestionValue protocol
    return nil
  }
  
  init(name: String) {
    self.name = name
    self.color = "tempColor" // when initializing categories in app delegate for first time, add temporary color
    self.totalHours = 0.0
  }
  
  var suggestionString: String {
    return "\(self.name)"
  }
  static func ==(lhs: Category, rhs: Category) -> Bool {
    return lhs.name == rhs.name
  }
  
  func getTotalHours() -> Double {
    return self.totalHours
  }
  func addToTotalHours(hoursToAdd: Double) {
    self.totalHours += hoursToAdd
    print("Category has \(self.totalHours) total hours.")
  }
  func getColor() -> String {
    return self.color
  }
  func setColor(color: String) {
    self.color = color
  }
  
}

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

struct Category: Codable {
  let name: String
  let color: String
  
  init(name: String) {
    self.name = name
    self.color = "tempColor"
  }
  init(name: String, color: String) {
    self.name = name
    self.color = color
  }
}

// SuggestionRow Protocol
extension Category: SuggestionValue {
  init?(string stringValue: String) {
    return nil
  }
  var suggestionString: String {
    return "\(self.name)"
  }
  static func ==(lhs: Category, rhs: Category) -> Bool {
    return lhs.name == rhs.name
  }
}

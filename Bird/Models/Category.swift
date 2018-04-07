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

struct Category : Codable {
  let category : String
  
  init(category : String) { self.category = category }
}

// SuggestionRow Protocol
extension Category : SuggestionValue {
  init?(string stringValue: String) {
    return nil
  }
  var suggestionString: String {
    return "\(self.category)"
  }
  static func ==(lhs: Category, rhs: Category) -> Bool {
    return lhs.category == rhs.category
  }
}

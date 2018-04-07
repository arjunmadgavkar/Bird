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

struct Activity : Codable {
  let activity : String
  
  init(activity : String) { self.activity = activity }
}

// SuggestionRow Protocol
extension Activity : SuggestionValue {
  init?(string stringValue: String) {
    return nil
  }
  var suggestionString: String {
    return "\(self.activity)"
  }
  static func ==(lhs: Activity, rhs: Activity) -> Bool {
    return lhs.activity == rhs.activity
  }
}

//
//  Utilities.swift
//  Bird
//
//  Created by Arjun Madgavkar on 3/29/18.
//  Copyright © 2018 Arjun Madgavkar. All rights reserved.
//

import UIKit

/** Global Functions **/
// Dates
func dateRangeToString(startDate: DateComponents, endDate: DateComponents) -> String {
  // Variables
  var startTime, endTime: String!
  var startTimeMorning, startTimePM, endTimeMorning, endTimePM: Bool!
  // Format minutes
  var startMinute = String(describing: startDate.minute!)
  if ( startMinute == "0" ) { startMinute = "" }
  else { startMinute = ":" + startMinute }
  var endMinute = String(describing: endDate.minute!)
  if ( endMinute == "0" ) { endMinute = "" }
  else { endMinute = ":" + endMinute }
  
  // Format hours
  var startHour = startDate.hour!
  if ( startHour == 0 ) { // midnight
    startHour = startHour + 12
    startTimeMorning = true
    startTimePM = false
  } else if ( startHour > 0 && startHour < 12)  { // morning
    startTimeMorning = true
    startTimePM = false
  } else if ( startHour >= 12 ) { // afternoon and evening
    if ( startHour != 12 ) { startHour = startHour - 12 } // don't subtract 12 if it's noon
    startTimeMorning = false
    startTimePM = true
  }
  var endHour = endDate.hour!
  if ( endHour == 0 ) { // midnight
    endHour = endHour + 12
    endTimeMorning = true
    endTimePM = false
  } else if ( endHour > 0 && endHour < 12 ) { // morning
    endTimeMorning = true
    endTimePM = false
  } else if ( endHour >= 12 ) { // afternoon and evening
    if ( endHour != 12 ) { endHour = endHour - 12 } // don't subtract 12 if it's noon
    endTimeMorning = false
    endTimePM = true
  }
  
  if ( startTimeMorning && endTimeMorning ) { // both am
    startTime = "\(startHour)" + "\(startMinute)"
    endTime = "\(endHour)" + "\(endMinute)" + "am"
  } else if ( startTimePM && endTimePM ) { // both pm
    startTime = "\(startHour)" + "\(startMinute)"
    endTime = "\(endHour)" + "\(endMinute)" + "pm"
  } else { // different
    startTime = "\(startHour)" + "\(startMinute)" + "am"
    endTime = "\(endHour)" + "\(endMinute)" + "pm"
  }
  return startTime + "-" + endTime
}
// Fonts
func AvenirNext(size: Float) -> UIFont { return UIFont(name: "Avenir Next", size: CGFloat(size))! }
func AvenirNextHeavy(size: Float) -> UIFont { return UIFont(name: "Avenir-Heavy", size: CGFloat(size))! }
func imagineRed() -> UIColor { return UIColor(rgb: 0xFF5964).withAlphaComponent(1.0) }
func imagineBlue() -> UIColor { return UIColor(rgb: 0x060A78).withAlphaComponent(1.0) }
func secondsInADay() -> Double { return 86400.0 }

// MARK: UIViewController
extension UIViewController {
  func showAlert(withTitle title: String?, message: String?) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
  }
}

// MARK: UIColor
extension UIColor {
  convenience init?(hex: String) {
    var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
    
    var rgb: UInt32 = 0
    
    var r: CGFloat = 0.0
    var g: CGFloat = 0.0
    var b: CGFloat = 0.0
    var a: CGFloat = 1.0
    
    let length = hexSanitized.characters.count
    
    guard Scanner(string: hexSanitized).scanHexInt32(&rgb) else { return nil }
    
    if length == 6 {
      r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
      g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
      b = CGFloat(rgb & 0x0000FF) / 255.0
      
    } else if length == 8 {
      r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
      g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
      b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
      a = CGFloat(rgb & 0x000000FF) / 255.0
      
    } else {
      return nil
    }
    
    self.init(red: r, green: g, blue: b, alpha: a)
  }
  
  convenience init(red: Int, green: Int, blue: Int) {
    assert(red >= 0 && red <= 255, "Invalid red component")
    assert(green >= 0 && green <= 255, "Invalid green component")
    assert(blue >= 0 && blue <= 255, "Invalid blue component")
    
    self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    
  }
  
  convenience init(rgb: Int) {
    self.init(
      red: (rgb >> 16) & 0xFF,
      green: (rgb >> 8) & 0xFF,
      blue: rgb & 0xFF
    )
  }
  func toHexString() -> String {
    var r:CGFloat = 0
    var g:CGFloat = 0
    var b:CGFloat = 0
    var a:CGFloat = 0
    
    getRed(&r, green: &g, blue: &b, alpha: &a)
    
    let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
    
    return String(format:"#%06x", rgb)
  }
  
  func toHex(alpha: Bool = false) -> String? {
    guard let components = cgColor.components, components.count >= 3 else {
      return nil
    }
    
    let r = Float(components[0])
    let g = Float(components[1])
    let b = Float(components[2])
    var a = Float(1.0)
    
    if components.count >= 4 {
      a = Float(components[3])
    }
    
    if alpha {
      return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
    } else {
      return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
  }
  
}

extension Date {
  /// Returns day of week written as a string (ex: "Wednesday")
  func dayOfWeek() -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"
    return dateFormatter.string(from: self).capitalized
  }
  /// Returns day of week written as a string (ex: "Wednesday")
  func dayOfWeekAbbreviation() -> String? {
    let weekdays = [
      "Sun",
      "Mon",
      "Tue",
      "Wed",
      "Thu",
      "Fri",
      "Sat"
    ]
    let num = Calendar.current.component(.weekday, from: self)
    //let number = Calendar.current.dateComponents([.weekday], from: self).weekday
    return weekdays[num - 1]
  }
  /// Returns the amount of years from another date
  func years(from date: Date) -> Int {
    return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
  }
  /// Returns the amount of months from another date
  func months(from date: Date) -> Int {
    return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
  }
  /// Returns the amount of weeks from another date
  func weeks(from date: Date) -> Int {
    return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
  }
  /// Returns the amount of days from another date
  func days(from date: Date) -> Int {
    return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
  }
  /// Returns the amount of hours from another date
  func hours(from date: Date) -> Int {
    return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
  }
  /// Returns the amount of minutes from another date
  func minutes(from date: Date) -> Int {
    return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
  }
  /// Returns the amount of seconds from another date
  func seconds(from date: Date) -> Int {
    return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
  }
  /// Returns the a custom time interval description from another date
  func offset(from date: Date) -> String {
    if years(from: date)   > 0 { return "\(years(from: date))y"   }
    if months(from: date)  > 0 { return "\(months(from: date))M"  }
    if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
    if days(from: date)    > 0 { return "\(days(from: date))d"    }
    if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
    if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
    if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
    return ""
  }
}

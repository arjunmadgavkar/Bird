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
  let dateStarted: Date
  var timePerDay: Double
  var numberOfCompletions: Int
  var percentageComplete: Double
  var datesCompleted = [Date]()
  var currentStreak: Int
  var longestStreak: Int
  var dayPartiallyStarted: Date?
  var amountCompleted: Double
  var partiallyComplete: Bool
  
  init(name: String, timePerDay: Double) {
    self.name = name
    self.timePerDay = timePerDay * 3600 // convert to seconds
    self.dateStarted = Date()
    self.numberOfCompletions = 0
    self.percentageComplete = 0.0
    self.datesCompleted = []
    self.currentStreak = 0
    self.longestStreak = 0
    self.dayPartiallyStarted = nil
    self.partiallyComplete = false
    self.amountCompleted = 0.0
  }
  
  func incrementCompletions(dateCompleted: Date) { // Increment streak + completions by 1
    datesCompleted.append(dateCompleted)
    datesCompleted.sort { (d1, d2) -> Bool in
      if ( d1 > d2 ) { return true }
      return false
    }
    self.numberOfCompletions += 1
  }
  
  func setCurrentStreak() {
    let cal = Calendar.current
    var streak = 1
    
    if ( datesCompleted.count == 0 ) {
      self.currentStreak = 0
      return
    }
    
    if ( datesCompleted.count > 1 ) {
      if ( Date().days(from: datesCompleted[0]) > 1 ) { // if today's date is more than 1 away from the most recent completion
        self.currentStreak = 0
        return
      }
      
      var counter = 0
      while ( counter < datesCompleted.count-1 ) {
        // Get days to compare
        let currentDate = datesCompleted[counter]
        let currentDay = cal.component(.day, from: currentDate)
        let nextDate = datesCompleted[counter+1]
        let nextDay = cal.component(.day, from: nextDate)
        
        if ( currentDay-1 == nextDay ) { // streak continues
          streak += 1
        } else { // it's ended, so break
          break
        }
        
        counter += 1
        
      }
    } else if ( datesCompleted.count == 1 ) {
      
      if ( Date().days(from: datesCompleted[0]) <= 1 ) { // only one value in the and its today
        self.currentStreak = 1
        return
      } else {
        self.currentStreak = 0
        return
      }
      
    }
    
    self.currentStreak = streak
    
  }
  
  func getCurrentStreak() -> Int {
    return self.currentStreak
  }
  
  func getNumberOfCompletions() -> Int {
    return self.numberOfCompletions
  }
  
  func getPercentageComplete() -> Double {
    let numberOfDaysSinceCreation = Double(Date().days(from: dateStarted)) // number of days since goal was created
    if ( numberOfDaysSinceCreation < 1 ) { // if it was created today
      if ( self.numberOfCompletions > 1 ) { // user created the goal today, but is adding information from days prior
        let datesAdded = self.datesCompleted.count
        let trueStartDate = Date().days(from: datesCompleted[datesAdded-1]) + 1 // first date entered
        let perc = Double(self.numberOfCompletions)/Double(trueStartDate)
        return (perc*100)
      }
      let percentage = Double(self.numberOfCompletions/1)
      return (percentage * 100)
    }
    self.percentageComplete = Double(self.numberOfCompletions) / numberOfDaysSinceCreation // percentage
    return self.percentageComplete * 100
  }
  
  func checkLongestStreak() {
    if ( self.currentStreak > self.longestStreak ) {
      self.longestStreak = self.currentStreak
    }
  }
  
  func getLongestStreak() -> Int {
    return self.longestStreak
  }
  
  func goalPartiallyComplete(startingDate: Date, amountCompleted: Double) {
    self.dayPartiallyStarted = startingDate
    self.amountCompleted += amountCompleted
    self.partiallyComplete = true
  }
  
  func checkGoalCompleted(newDate: Date, amountCompleted: Double) {
    if ( newDate.days(from: self.dayPartiallyStarted! ) < 1 ) {
      if ( self.amountCompleted + amountCompleted >= timePerDay ) {
        incrementCompletions(dateCompleted: self.dayPartiallyStarted!)
        setCurrentStreak()
        // Reset
        self.dayPartiallyStarted = nil
        self.amountCompleted = 0.0
        self.partiallyComplete = false
      }
    } else {
      // Reset
      self.dayPartiallyStarted = nil
      self.amountCompleted = 0.0
      self.partiallyComplete = false
    }
  }
  
  func getPartiallyComplete() -> Bool {
    return self.partiallyComplete
  }
  
  
  func editTimePerDay(newTimePerDay: Double) { self.timePerDay = newTimePerDay } // Change goal of time per day
  
  
}






















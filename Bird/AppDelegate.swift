//
//  AppDelegate.swift
//  Bird
//
//  Created by Arjun Madgavkar on 3/29/18.
//  Copyright © 2018 Arjun Madgavkar. All rights reserved.
//

import UIKit
import Disk

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var timeBlocks = [TimeBlock]()
  var categories = [Category]()
  var goals = [Goal]()
  var activities = [Activity]()

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    /*
    Testing:
 
    Remove everything --
     TimeBlock.deleteAllTimeBlocks()
     do { try Disk.remove("categories.json", from: .documents) }
     catch let error { print("\(error)") }
     do { try Disk.remove("activities.json", from: .documents) }
     catch let error { print("\(error)") }
     do { try Disk.remove("goals.json", from: .documents) }
     catch let error { print("\(error)") }
     */
    
//    do { try TimeBlock.deleteMostRecentTimeBlock() }
//    catch { print("error") }
    
    //TimeBlock.deleteAllTimeBlocks()
//    do { try Disk.remove("categories.json", from: .documents) }
//    catch let error { print("\(error)") }
//    do { try Disk.remove("activities.json", from: .documents) }
//    catch let error { print("\(error)") }
//    do { try Disk.remove("goals.json", from: .documents) }
//    catch let error { print("\(error)") }
    
    // Retrieve data
//    do {
//      var timeBlock: TimeBlock?
//      timeBlock = try Disk.retrieve("earliestTimeBlock.json", from: .documents, as: TimeBlock.self)
//      TimeBlock.setEarliestTimeBlock(timeBlock: timeBlock!)
//    } catch let error {
//      print("\(error)")
//    }
    do { categories = try Disk.retrieve("categories.json", from: .documents, as: [Category].self) }
    catch let error { print("\(error)") }
    do { activities = try Disk.retrieve("activities.json", from: .documents, as: [Activity].self) }
    catch let error { print("\(error)") }
//    do { goals = try Disk.retrieve("goals.json", from: .documents, as: [Goal].self) }
//    catch let error { print("\(error)") }
    
    
    var addCategories = false
    if ( categories.count == 0 ) {
      let namesOfCategories = ["Commute", "Deep Work", "Exercise", "Family", "Learning", "Mindfulness", "Other", "Relax", "Sleep", "Social", "Waste", "Work"]
      var i = 0
      while (i < 11) {
        categories.append(Category(name: namesOfCategories[i]))
        i+=1
      }
      addCategories = true
    }
    
    
    var addActivities = false
    if ( activities.count == 0 ) {
      let namesOfActivities = ["Code", "Eat", "Get Ready", "Hike", "Listen to Music", "Listen to Podcast", "Meditate", "Read", "Run", "Schoolwork", "Sleep", "Think", "TV"]
      var i = 0
      while (i < 11) {
        activities.append(Activity(name: namesOfActivities[i]))
        i+=1
      }
      addActivities = true
    }
    
    // Save to disk
    if ( addCategories ) {
      do { try Disk.save(categories, to: .documents, as: "categories.json") }
      catch let error { print("\(error)") }
    }
    if ( addActivities ) {
      do { try Disk.save(activities, to: .documents, as: "activities.json") }
      catch let error { print("\(error)") }
    }

    
    return true
    
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }


}


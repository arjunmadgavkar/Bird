//
//  GoalsCollectionVC.swift
//  Bird
//
//  Created by Arjun Madgavkar on 4/18/18.
//  Copyright © 2018 Arjun Madgavkar. All rights reserved.
//

import UIKit
import Disk

class GoalsCollectionVC: UICollectionViewController {
  var goals = [Goal]()

  override func viewDidLoad() {
    super.viewDidLoad()
    viewControllerSetUp()
    //dataPull()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(false)
    dataPull()
    self.collectionView?.reloadData()
  }
  
  // MARK: VC Set Up
  func viewControllerSetUp() {
    self.title = "Goals"
    self.navigationController?.navigationBar.prefersLargeTitles = true
    self.navigationController?.navigationBar.largeTitleTextAttributes = [
      NSAttributedStringKey.foregroundColor: UIColor.black,
      NSAttributedStringKey.font: AvenirNextHeavy(size: 40.0)
    ]
    // Set Image
    var image = UIImage(named: "add_button")
    image = image?.withRenderingMode(.alwaysOriginal)
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style:.plain, target: self, action: #selector(addBtnClicked))
    // Get rid of back button on next screen
    let backItem = UIBarButtonItem()
    backItem.title = ""
    navigationItem.backBarButtonItem = backItem
  }
  
  func dataPull() { // Get data saved on Disk
    do {
      goals = try Disk.retrieve("goals.json", from: .documents, as: [Goal].self)
      for goal in goals {
        goal.setCurrentStreak()
        goal.checkLongestStreak()
      }
    }
    catch let error { print("\(error)") }
  }
  
  func didEdit() {
    dataPull()
    self.collectionView?.reloadData()
  }
  
  
  // MARK: Segue
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if ( segue.identifier == "goToAddGoalVC" ) {
      let addGoalVC = segue.destination as! AddGoalVC
      addGoalVC.delegate = self
    }
    if ( segue.identifier == "goToGoalDetailVC" ) {
      if let cell = sender as? UICollectionViewCell, // get the cell that was the sender
        let indexPath = self.collectionView?.indexPath(for: cell) { // from that cell get the indexPath
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        let vc = segue.destination as! GoalDetailVC
        vc.goal = goals[indexPath.row]
      }
    }
  }
  
  @IBAction func unwindToGoalsVC(segue: UIStoryboardSegue) {
    if let _ = segue.source as? EditGoalVC {
      didEdit()
    }
  }
  
  // MARK: Button Actions
  @objc func addBtnClicked() {
    performSegue(withIdentifier: "goToAddGoalVC", sender: nil)
  }
}

// MARK: UICollectionViewDataSource
extension GoalsCollectionVC {
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return goals.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GoalCell", for: indexPath) as! GoalsCollectionViewCell
    let goal = goals[indexPath.row]
    
    // Set labels
    cell.goalTextLabel.text = goal.name
    cell.streakCountLabel.text = "\(goal.getCurrentStreak())" + "🔥"
    
    // Set colors
    cell.layer.borderColor = UIColor.black.cgColor
    cell.layer.borderWidth = 1
    
    return cell
  }
}

// MARK: UICollectionViewDelegate
extension GoalsCollectionVC {
  /*
   // Uncomment this method to specify if the specified item should be selected
   override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
   return true
   }
   */
}

// MARK: UICollectionViewDelegateFlowLayout
extension GoalsCollectionVC: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.frame.width, height: 50)
  }
  // This function determines the spacing between rows
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0.0
  }
  // This function determines the spacing between items
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0.0
  }
}

// MARK: AddGoalDelegate
extension GoalsCollectionVC: AddGoalDelegate {
  func didAdd(goal: Goal) {
    dataPull() // get new goals
    self.collectionView?.reloadData()
  }
}























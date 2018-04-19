//
//  GoalsCollectionVC.swift
//  Bird
//
//  Created by Arjun Madgavkar on 4/18/18.
//  Copyright © 2018 Arjun Madgavkar. All rights reserved.
//

import UIKit

class GoalsCollectionVC: UICollectionViewController {
  var goals = [Goal]()

  override func viewDidLoad() {
    super.viewDidLoad()
    viewControllerSetUp()
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
    return 1
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GoalCell", for: indexPath) as! GoalsCollectionViewCell
    cell.goalTextLabel.text = "Justin Greg"
    cell.streakCountLabel.text = "500🔥"
    
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
  
}























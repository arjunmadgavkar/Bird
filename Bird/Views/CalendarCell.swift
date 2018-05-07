//
//  CalendarCell.swift
//  Bird
//
//  Created by Arjun Madgavkar on 4/8/18.
//  Copyright © 2018 Arjun Madgavkar. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarCell: JTAppleCell {
  @IBOutlet weak var calendarCellLabel: UILabel!
  @IBOutlet weak var dayLabel: UILabel!
  @IBOutlet weak var selectedView: UIView!
}

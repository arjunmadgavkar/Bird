//
//  Protocols.swift
//  Bird
//
//  Created by Arjun Madgavkar on 4/5/18.
//  Copyright © 2018 Arjun Madgavkar. All rights reserved.
//

import Foundation

// Create the AddBlockDelegate, which will be used to communicate between AddBlockVC and YourDayVC
protocol AddBlockDelegate : class { func didUpdate(timeBlock: TimeBlock, newTimeBlocks: [TimeBlock]) }
//protocol EditBlockDelegate : class { func didEdit(timeBlock: TimeBlock, newTimeBlocks: [TimeBlock]) }

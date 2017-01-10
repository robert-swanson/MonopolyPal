//
//  IncrementerCellController.swift
//  MonopolyPal
//
//  Created by Robert Swanson on 8/18/16.
//  Copyright © 2016 Robert Swanson. All rights reserved.
//

import Foundation
import UIKit

class IncrementerCellController: UITableViewCell {
	@IBOutlet weak var Label: UILabel!
	@IBOutlet weak var Incrementer: UIStepper!
	var name: String?
	@IBAction func Changed(_ sender: AnyObject) {
		Label.text = name! + ": \(Int(Incrementer.value))"
	}
}


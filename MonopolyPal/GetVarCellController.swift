//
//  GetVarCellController.swift
//  MonopolyPal
//
//  Created by Robert Swanson on 7/21/16.
//  Copyright © 2016 Robert Swanson. All rights reserved.
//

import Foundation
import UIKit

class GetVarCellController: UITableViewCell, UITextFieldDelegate {
	
	@IBOutlet weak var TextField: UITextField!
	var isLast: Bool = false
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool
	{
		textField.resignFirstResponder()
		if isLast
		{
			NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "SubmitAction"), object: nil))
		}
		return true;
	}
	

	
}

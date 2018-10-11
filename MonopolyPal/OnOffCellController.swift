//
//  OnOffCellViewController.swift
//  MonopolyPal
//
//  Created by Robert Swanson on 8/3/16.
//  Copyright © 2016 Robert Swanson. All rights reserved.
//

import Foundation
import UIKit

class OnOffCellController: UITableViewCell {
	var isOn: Bool = true
	
	@IBOutlet weak var Switch: UISwitch!
	@IBOutlet weak var label: UILabel!
	
	@IBAction func changed(_ sender: AnyObject) {
		var game = (PlistManager.sharedInstance.getValueForKey("Game", key: "Game")! as! [String:AnyObject])
		var settings = game["Settings"] as! [String:AnyObject]
		
		let a = sender
		let b = a as! UISwitch
		let value = b.isOn
//		print(self.label.text!," is ",value)
		let s = self.label.text!
		switch (s)
		{
		case "Disable Auto Lock":
			UIApplication.shared.isIdleTimerDisabled = value
			print("Dissabled autolock: " + ( value).description)
			settings["AutoLock"] = value ? "true" as AnyObject : "false" as AnyObject
		case "Order history top as latest":
			settings["Order"] = value ? "true" as AnyObject : "false" as AnyObject
		case "Allow Debt":
			settings["Allow Debt"] = value ? "true" as AnyObject : "false" as AnyObject
		default:
			break
		}
		game["Settings"] = settings as AnyObject?
		PlistManager.sharedInstance.saveValue("Game", value: game as AnyObject, forKey: "Game")
	}
	
	
}

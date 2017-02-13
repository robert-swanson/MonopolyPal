
//
//  TableViewControllerTemplate.swift
//  MonopolyPal
//
//  Created by Robert Swanson on 8/7/16.
//  Copyright © 2016 Robert Swanson. All rights reserved.
//


import UIKit
import Foundation

class TableViewControllerTemplate: UITableViewController {
	
	// MARK: - Vars
	var game = (PlistManager.sharedInstance.getValueForKey("Game", key: "Game")! as! [String:AnyObject])
	var settings = [String:AnyObject]()
	
	
	// MARK:- Custom
	func saveGame ()
	{
		PlistManager.sharedInstance.saveValue("Game", value: game as AnyObject, forKey: "Game")
	}
	
	func updateGame ()
	{
		game = PlistManager.sharedInstance.getValueForKey("Game", key: "Game")! as! [String:AnyObject]
	}
	func convertStringToBool(_ string: String) -> Bool?
	{
		if (string == "Yes" || string == "True" || string == "true")
		{
			return true
		}
		if (string == "No" || string == "False" || string == "false")
		{
			return false
		}
		else
		{
			print("ERROR-Could not convert string: \(string) to bool")
			return nil
		}
	}
	
	// MARK: - Initializer
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		updateGame()
		tableView.reloadData()
		self.clearsSelectionOnViewWillAppear = false
		super.viewWillAppear(animated)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	
	// MARK: - Alerts
	func resetGame()
	{
		guard let path = Bundle.main.path(forResource: "Game", ofType: "plist") else { return }
		
		let newGame = NSDictionary(contentsOfFile: path)!
		
		
		PlistManager.sharedInstance.saveValue("Game", value: newGame["Game"] as! [String:AnyObject] as AnyObject, forKey: "Game")
	}
	
	// MARK: - Table View
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch (indexPath.section, indexPath.row) {
		case (1,0):
			let resetAlert = UIAlertController(title: "Are you sure?", message: "Are you sure you want to reset the game? This will delete all players and clear the history. You cannot undo this action.", preferredStyle: .alert)
			let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
			let resetAction = UIAlertAction(title: "Reset Game", style: .destructive, handler: ({
				UIAlertAction in
				self.resetGame()
			}))
			resetAlert.addAction(cancelAction)
			resetAlert.addAction(resetAction)
			present(resetAlert, animated: true, completion: nil)
			
		default:
			break
		}
		tableView.deselectRow(at: indexPath, animated: true)
	}
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 3
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return 3
		case 1:
			return 1
		default:
			return 2
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let row = indexPath.row
		let section = indexPath.section
		
		var identifier = ""
		
		switch section {
		case 0:
			switch row {
			case 0:
				identifier = "Selection"
			default:
				identifier = "On/Off"
			}
		case 1:
			identifier = "Reset"
		default:
			switch row {
			case 0:
				identifier = "Selection"
			default:
				identifier = "Manage"
			}
		}
		
		let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
		
		if (section == 0)
		{
			if (row == 0)
			{
				cell.textLabel?.text = "Start Cash"
				if let cash = settings["Start Cash"]
				{
					cell.detailTextLabel?.text = "\(Int(cash as! String)!)"
				}
				else
				{
					cell.detailTextLabel?.text = ""
				}
			}
			if (row == 1)
			{
				let setting = cell as! OnOffCellController
				setting.label.text = "Disable Auto Lock"
				if let set = settings["AutoLock"] {
					setting.Switch.setOn((set as! String == "true" ? true : false), animated: false)
				}
				return setting
			}
			if (row == 2)
			{
				let setting = cell as! OnOffCellController
				setting.label.text = "Order history top as latest"
				if let set = settings["Order"] {
					setting.Switch.setOn((set as! String == "true" ? true : false), animated: false)
				}
				
				return setting
			}
		}
		if (section == 1)
		{
			cell.textLabel?.text = "Reset Game"
		}
		if (section == 2)
		{
			if (row == 0)
			{
				cell.textLabel?.text = "Select Game"
				if let template = settings["Selected Game"]
				{
					cell.detailTextLabel?.text = "\(Int(template as! String)!)"
				}
				else
				{
					cell.detailTextLabel?.text = ""
				}
				
			}
			if (row == 1)
			{
				cell.textLabel?.text = "Manage Templates"
				if let templates = settings["Templates"]
				{
					let arr = templates as! NSMutableArray
					cell.detailTextLabel?.text = "\(arr.count)"
				}
				else
				{
					cell.detailTextLabel?.text = ""
				}
			}
		}
		return cell
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return false
	}
	
	
}


//
//  SettingsViewController.swift
//  MonopolyPal
//
//  Created by Robert Swanson on 7/31/16.
//  Copyright © 2016 Robert Swanson. All rights reserved.
//

import UIKit
import Foundation

class SettingsViewController: UITableViewController {
	
	// MARK: - Vars
	var game = (PlistManager.sharedInstance.getValueForKey("Game", key: "Game")! as! [String:AnyObject])
	var settings = [String:AnyObject]()
	
	
	// MARK:- Custom
	func special(command: String){
		let commands = command.components(separatedBy: " ")
		if commands.count != 2 {
			changeSettingAlert(setting: "Basic")
			return
		}
		let color = commands[1]
		var themes = settings["Themes"] as! [String:AnyObject]
		let sel = settings["Selected Theme"] as! String
		var colors = themes[sel] as! [String:String]
		switch commands[0] {
		case "bar":
			colors["Top Bar"] = color
		case "title":
			colors["Titles"] = color
		case "button":
			colors["Bar Buttons"] = color
		case "back":
			colors["Background"] = color
		case "cell":
			colors["Cells"] = color
		case "cellt":
			colors["Cell Text"] = color
		case "tab":
			colors["Bottom Bar"] = color
		case "unsel":
			colors["Unselected Bar Buttons"] = color
		case "sel":
			colors["Selected Bar Buttons"] = color
		default:
			print("Unkown Command")
			changeSettingAlert(setting: "Basic")
			return
		}
		let name = settings["Selected Theme"] as! String
		themes[name] = colors as AnyObject
		settings["Themes"] = themes as AnyObject
		saveGame()
	}
	func addUnit(to: Int)-> String{
		var rv = ""
		var unit = settings["Unit"] as! String
		if (unit.remove(at: unit.startIndex) == "<"){
			rv = unit + String(to)
		}
		else{
			rv = String(to) + unit
		}
		return rv
	}
	func changeUnit(unit: String)
	{
		settings["Unit"] = unit as AnyObject?
		saveGame()
	}
	func saveGame ()
	{
		game["Settings"] = settings as AnyObject?
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
	override func viewDidAppear(_ animated: Bool) {
		tableView.reloadData()
	}
	override func viewDidLoad() {
		
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		updateGame()
		tableView.reloadData()
		self.clearsSelectionOnViewWillAppear = false
		super.viewWillAppear(animated)
		settings = game["Settings"] as! [String:AnyObject]
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
		changeSettingAlert(setting: "Special")
	}
	
	// MARK: - Alerts
	func resetGame()
	{
		guard let path = Bundle.main.path(forResource: "Game", ofType: "plist") else { return }
		
		tabBarController?.tabBar.items?[1].badgeValue = nil
		
		let newGame = NSDictionary(contentsOfFile: path)!
		PlistManager.sharedInstance.saveValue("Game", value: newGame["Game"] as! [String:AnyObject] as AnyObject, forKey: "Game")
	}
	func changeSettingAlert(setting: String)
	{
		var title = ""
		var mess = ""
		enum Style{
			case GetNum
			case GetString
			case Unit
			case Basic
		}
		var style: Style = .GetNum
		switch setting{
		case "Start Cash":
			title = "Start Cash"
			mess = "What would you like the starting amount of each player to be?"
		case "Unit":
			title = "Game Unit"
			mess = "What unit would you like to use to show players score?"
			style = .Unit
		case "Special":
			title = "Special Access"
			mess = "This activates when you shake your device to allow special commands to custimize the app. If you activated this by accident, press cancel. Commands are: bar title button back cell cellt tab sel unsel"
			style = .GetString
		case "Basic":
			style = .Basic
			title = "Alert"
			mess = "Error"
		default:
			print("Did not recognize Setting alert type.")
		}
		var alert = UIAlertController()
		if style == .GetNum || style == .GetString {
			alert = UIAlertController(title: title, message: mess, preferredStyle: .alert)
			let okAction = UIAlertAction(title: "OK",
			                             style: .default,
			                             handler:
				{
					UIAlertAction in
					
					let startAmount = alert.textFields![0].text!
					if style == Style.GetNum
					{
						if (self.settings[setting] != nil) {
							if let cash = (Int)(startAmount){
								self.settings[setting] = cash as AnyObject?
							}
							else{
								let newAlert = UIAlertController(title: "Input Error", message: "The input you provided was not valid", preferredStyle: .alert)
								self.present(newAlert, animated: true, completion: nil)
							}
						}
					}
					else if style == Style.GetString{
						self.special(command: startAmount)
					}
					self.tableView.reloadData()
					//Do Stuff
			}
			)
			let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
			alert.addAction(okAction)
			alert.addAction(cancelAction)
			alert.addTextField { (textF) in
				textF.placeholder = (style == Style.GetNum) ? "Enter Amount" : "Enter Command"
				if style == .GetNum{
					textF.keyboardType = .numberPad
				}
			}
			
			
		}
		else if(style == .Unit)
		{
			
			alert = UIAlertController(title: title, message: mess, preferredStyle: .actionSheet)
			let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
			let $ = UIAlertAction(title: "$", style: .default, handler: {
				UIAlertAction in
				self.changeUnit(unit: "<$")
				self.tableView.reloadData()
			})
			let points = UIAlertAction(title: "Points", style: .default, handler: {
				UIAlertAction in
				self.changeUnit(unit: "> points")
				self.tableView.reloadData()
			})
			let other = UIAlertAction(title: "Other", style: .default, handler: {
				UIAlertAction in
				self.performSegue(withIdentifier: "unit", sender:self)
				
			})
			alert.addAction(cancel)
			alert.addAction(other)
			alert.addAction($)
			alert.addAction(points)
		}
		if style == .Basic{
			alert = UIAlertController(title: title, message: mess, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
		}
		present(alert, animated: true, completion: nil)
	}
	// MARK: - Table View
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch (indexPath.section, indexPath.row) {
		case (0,0):
			changeSettingAlert(setting: "Start Cash")
		case (0,1):
			changeSettingAlert(setting: "Unit")
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
		return 4
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return 5
		case 1:
			return 1
		case 2:
			return 2
		default:
			return 1
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let row = indexPath.row
		let section = indexPath.section
		
		var identifier = ""
		
		switch (section,row) {
		case (0,0):
			identifier = "Basic"
		case (0,1):
			identifier = "Basic"
		case (0,2):
			identifier = "On/Off"
		case (0,3):
			identifier = "On/Off"
		case (0,4):
			identifier = "On/Off"
		case (1,0):
			identifier = "Reset"
		case (2,0):
			identifier = "Selection"
		case (2,1):
			identifier = "Manage"
		case (3,0):
			identifier = "Theme"
		default:
			print("Extra rows")
		}
		
		let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
		
		if (section == 0)
		{
			if (row == 0)
			{
				cell.textLabel?.text = "Start Cash"
				if let cash = settings["Start Cash"] as! String?
				{
					cell.detailTextLabel!.text = addUnit(to: Int(cash)!)
				}
				else
				{
					cell.detailTextLabel?.text = ""
				}
			}
			if (row == 1){
				cell.textLabel?.text = "Cash/Point Unit"
				if var unit = settings["Unit"] as! String?
				{
					unit.remove(at: unit.startIndex)
					cell.detailTextLabel!.text = unit
				}
				else
				{
					cell.detailTextLabel?.text = ""
				}
				
			}
			
			if (row == 2){
				let setting = cell as! OnOffCellController
				setting.label.text = "Disable Auto Lock"
				if let set = settings["AutoLock"] {
					setting.Switch.setOn((set as! String == "true" ? true : false), animated: false)
				}
				return setting
			}
			if (row == 3)
			{
				let setting = cell as! OnOffCellController
				setting.label.text = "Order history top as latest"
				if let set = settings["Order"] {
					setting.Switch.setOn((set as! String == "true" ? true : false), animated: false)
				}
				
				return setting
			}
			if (row == 4)
			{
				let setting = cell as! OnOffCellController
				setting.label.text = "Allow Debt"
				if let set = settings["Allow Debt"] {
					setting.Switch.setOn((set as! String == "true" ? true : false), animated: false)
				}
				
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
					cell.detailTextLabel?.text = "\(template as! String)"
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
		if section == 3
		{
			cell.textLabel?.text = "Themes"
			if let theme = settings["Selected Theme"] as! String?
			{
				cell.detailTextLabel?.text = theme
			}
			else
			{
				cell.detailTextLabel?.text = ""
			}
		}
		return cell
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return false
	}
	
	
}


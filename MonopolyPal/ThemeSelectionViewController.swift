//
//  ThemeSelectionViewController.swift
//  MonopolyPal
//
//  Created by Robert Swanson on 1/5/17.
//  Copyright © 2017 Robert Swanson. All rights reserved.
//

import Foundation
import UIKit
class ThemeSelectionViewController: UITableViewController {
	
	// MARK: - Vars
	var cellColor = UIColor()
	var cellT = UIColor()
	var game = (PlistManager.sharedInstance.getValueForKey("Game", key: "Game")! as! [String:AnyObject])
	var settings = [String:AnyObject]()
	var names = [String]()
	var themes = [String:[String:String]]()
	var selected = String()
	
	
	// MARK:- Custom
	func customTableColors(){
		func getColor(fromString: String)-> UIColor{
			if (fromString.characters.first == "#"){		//Hex color
				var newColor = fromString
				newColor.remove(at: newColor.startIndex)
				return UIColor(netHex: Int(newColor)!)
			}
			else{			//RGB
				let comp = fromString.components(separatedBy: ",")
				return UIColor(red: Int(comp[0])!, green: Int(comp[1])!, blue: Int(comp[2])!)
			}
		}
		let themes = settings["Themes"] as! [String:[String:String]]
		let selected = settings["Selected Theme"] as! String
		let colors = themes[selected]!
		
		let background = colors["Background"]
		self.tableView.backgroundColor = getColor(fromString: background!)
		
		let cell = colors["Cells"]!
		cellColor = getColor(fromString: cell)
		
		let cellText = colors["Cell Text"]!
		cellT = getColor(fromString: cellText)
		
		
	}

	func addTheme(_ sender: AnyObject)
	{
		let alert = UIAlertController(title: "New Theme", message: "What would you like to call this theme?", preferredStyle: .alert)
		let okAction = UIAlertAction(title: "OK",
		                             style: .default,
		                             handler:
			{
				UIAlertAction in
				
				let name = alert.textFields![0].text!
				self.names.append(name)
				self.themes[name] = self.themes["Basic Monopoly"]
				self.saveGame()
				self.tableView.reloadData()
		})
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		alert.addAction(okAction)
		alert.addAction(cancelAction)
		alert.addTextField { (textF) in
			textF.placeholder = "Enter Name"
		}
		
		present(alert, animated: true, completion: nil)
	}
	func done(){
		self.dismiss(animated: true, completion: nil)
		saveGame()
	}
	func saveGame ()
	{
		settings["Theme Names"] = names as AnyObject
		settings["Themes"] = themes as AnyObject
		settings["Selected Theme"] = selected as AnyObject
		game["Settings"] = settings as AnyObject
		PlistManager.sharedInstance.saveValue("Game", value: game as AnyObject, forKey: "Game")
	}
	
	func updateGame ()
	{
		game = PlistManager.sharedInstance.getValueForKey("Game", key: "Game")! as! [String:AnyObject]
		settings = game["Settings"] as! [String : AnyObject]
		themes = settings["Themes"] as! [String : [String : String]]
		names = settings["Theme Names"] as! [String]
		selected = settings["Selected Theme"] as! String
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
	func update() {
		let sel = settings["Selected Theme"] as! String
		let themes = settings["Themes"] as! [String: AnyObject]
		let colors = themes[sel] as! [String:String]
		
		UINavigationBar.appearance().barTintColor = getColor(fromString: colors["Top Bar"]!)
		UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: getColor(fromString: colors["Titles"]!)]
		UIBarButtonItem.appearance().tintColor = getColor(fromString: colors["Bar Buttons"]!)
		UITabBar.appearance().barTintColor = getColor(fromString: colors["Top Bar"]!)
		UITabBar.appearance().tintColor = getColor(fromString: colors["Selected Bar Buttons"]!)
		UITabBar.appearance().unselectedItemTintColor = getColor(fromString: colors["Unselcted Bar Buttons"]!)
	}
	// MARK: - Segues
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let controller = (segue.destination as! UINavigationController).topViewController as! ThemeEditViewController
		controller.this = names[(tableView.indexPathForSelectedRow?.row)!]
	}
	// MARK: - Initializer
	override func setEditing(_ editing: Bool, animated: Bool) {
		if (editing)
		{
			let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTheme(_:)))
			self.navigationItem.rightBarButtonItem = addButton
		}
		else
		{
			self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
		}
		tableView.reloadData()
		super.setEditing(editing, animated: animated)
	}
	
	
	override func viewDidLoad() {
		self.navigationItem.leftBarButtonItem = self.editButtonItem
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
		tableView.allowsSelectionDuringEditing = true
		updateGame()
		super.viewDidLoad()
		customTableColors()
		print("Theme Selection View Did load")
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
	func getColor(fromString: String)-> UIColor{
		func getInt(fromString: String)-> CGFloat{
			return CGFloat(Float(fromString
				)!)
		}		//RGB
		let comp = fromString.components(separatedBy: ",")
		let a = (comp.count == 4) ? comp[3] : "255"
		//				return UIColor(red: getCGFloat(fromString: comp[0]), green: getCGFloat(fromString: comp[1]), blue: getCGFloat(fromString: comp[2]), alpha: getCGFloat(fromString: a))
		let c = UIColor(red: Int(comp[0])!
			, green: Int(comp[1])!, blue: Int(comp[2])!)
		return c.withAlphaComponent(CGFloat(Float(a)!))
		
		
		//			return c
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
		if isEditing{
			self.performSegue(withIdentifier: "edit", sender:self)
		}
		else{
			selected = names[indexPath.row]
			settings["Selected Game"] = selected as AnyObject?
			tableView.deselectRow(at: indexPath, animated: true)
			saveGame()
			update()
			tableView.reloadData()
		}
	}
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return names.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
		let name = names[indexPath.row]
		cell?.textLabel?.text = name
		if !isEditing && selected == name {
			cell?.accessoryType = .checkmark
		}
		else{
			cell?.accessoryType = .none
		}
		cell?.backgroundColor = cellColor
		cell?.textLabel?.textColor = cellT
		return cell!
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return false
	}
	
	
}


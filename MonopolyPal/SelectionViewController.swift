//
//  SelectionViewController.swift
//  MonopolyPal
//
//  Created by Robert Swanson on 8/7/16.
//  Copyright © 2016 Robert Swanson. All rights reserved.
//

import UIKit
import Foundation

class SelectionViewController: UITableViewController {
	
	// MARK: - Vars
	var game = (PlistManager.sharedInstance.getValueForKey("Game", key: "Game")! as! [String:AnyObject])
	var settings = [String:AnyObject]()
	var games = [String]()
	var selected: Int? = nil
	var templates: AnyObject?
	
	// MARK:- Custom
	func findSel()
	{
		games = templates?.allKeys as! [String]
		if let s = games.index(of: settings["Selected Game"] as! String){
			selected = s
		}
		else{
			print("No Selected Game")
		}
		print(games)
	}
	func addGame(_ sender: AnyObject)
	{
		alert(type: "Add")
	}
	func saveGame ()
	{
		game["Templates"] = templates
		game["Settings"] = settings as AnyObject?
		PlistManager.sharedInstance.saveValue("Game", value: game as AnyObject, forKey: "Game")
		templates = self.game["Templates"]!
		games = templates?.allKeys as! [String]
		print(games)

	}
	
	func updateGame ()
	{
		game = PlistManager.sharedInstance.getValueForKey("Game", key: "Game")! as! [String:AnyObject]
	}

	
	// MARK: - Initializer
	func done()
	{
		saveGame()
		self.dismiss(animated: true, completion: nil)
//		(self.navigationController?.parent as! UITableViewController).tableView.reloadData()
		
	}
	override func viewDidLoad() {
		templates = self.game["Templates"]!
		games = templates?.allKeys as! [String]
		settings = game["Settings"] as! [String : AnyObject]
		let sel = settings["Selected Game"]! as? String
		selected = games.index(of: sel!)
		self.navigationItem.leftBarButtonItem = self.editButtonItem
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
		super.viewDidLoad()
	}
	override func setEditing(_ editing: Bool, animated: Bool) {
		if (editing)
		{
		let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addGame(_:)))
		self.navigationItem.rightBarButtonItem = addButton
		}
		else
		{
			self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))		}
		super.setEditing(editing, animated: animated)
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
	func alert(type: String)
	{
		var title = ""
		var mess = ""
		
		switch type{
		case "Add":
			title = "New Game Template"
			mess = "What is the name of the game you would like to add?"
		default:
			print("Did not recognize Setting alert type.")
		}
		let alert = UIAlertController(title: title, message: mess, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "OK",
		                             style: .default,
		                             handler:
			{
				UIAlertAction in
				
				let name = alert.textFields![0].text!
				var t = self.templates as! Dictionary<String,AnyObject>
				t[name] = self.game["New Game Template"] as AnyObject?
				self.templates = t as AnyObject?
				self.saveGame()
				self.findSel()
				let i = self.games.index(of: name)
				let ip = IndexPath(row: i!, section: 0)
				self.tableView.insertRows(at: [ip], with: .fade)
				self.tableView.reloadData()
				//Do Stuff
		}
		)
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		alert.addAction(okAction)
		alert.addAction(cancelAction)
		alert.addTextField { (textF) in
			textF.placeholder = "Enter Name"
		}
		
		present(alert, animated: true, completion: nil)
	}
	// MARK: - Table View
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selected = indexPath.row
		let Game: String = games[selected!]
		print(Game)
		settings["Selected Game"] = Game as AnyObject?
		print(self.settings["Selected Game"] as! String)
		
		
		tableView.deselectRow(at: indexPath, animated: true)
		tableView.reloadData()
		saveGame()
	}
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
//		print("Count: " + String(games.count))
		return games.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "check", for: indexPath)
		cell.textLabel?.text = games[indexPath.row]
		if (indexPath.row == selected) {
			cell.accessoryType = .checkmark
		}
		else{
			cell.accessoryType = .none
		}
		return cell
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		if games[indexPath.row] == "Monopoly"
		{
			return false
		}
		// Return false if you do not want the specified item to be editable.
		return true
	}
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			
			let deletePlayerAlert = UIAlertController(title: "Delete Game", message: "Are you sure you want to delete this game? You cannot undo this action", preferredStyle: .alert)
			let deleteAction = UIAlertAction(title: "Delete",
			                                 style: .destructive,
			                                 handler:
				{
					UIAlertAction in
					let name: String = self.games.remove(at: indexPath.row)
					var t = self.templates! as! Dictionary<String,AnyObject>
					t.removeValue(forKey: name)
					
					self.templates = t as AnyObject
					self.findSel()
					if self.selected == indexPath.row{
						self.settings["Selected Game"] = "Monopoly" as AnyObject?
						self.selected = self.games.index(of: "Monopoly")
					}
					tableView.deleteRows(at: [indexPath], with: .fade)
					self.saveGame()
					tableView.reloadData()
			}
			)
			let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
			deletePlayerAlert.addAction(deleteAction)
			deletePlayerAlert.addAction(cancelAction)
			present(deletePlayerAlert, animated: true, completion: nil)
			
			
			
		} else if editingStyle == .insert {
			// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
		}
	}
	
	
}


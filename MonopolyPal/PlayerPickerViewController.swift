//
//  PlayerPickerViewController.swift
//  MonopolyPal
//
//  Created by Robert Swanson on 8/17/16.
//  Copyright © 2016 Robert Swanson. All rights reserved.
//

import UIKit
import Foundation

class PlayerPickerMenu: UITableViewController {
	
	// MARK: - Vars
	var game = (PlistManager.sharedInstance.getValueForKey("Game", key: "Game")! as! [String:AnyObject])
	var settings = [String:AnyObject]()
	var players = [String]()
	var selectedPlayers: [String] = []
	var senderPlayer: String?
	
	
	// MARK:- Custom
	func saveGame ()
	{
		PlistManager.sharedInstance.saveValue("Game", value: game as AnyObject, forKey: "Game")
	}
	func updateGame ()
	{
		game = PlistManager.sharedInstance.getValueForKey("Game", key: "Game")! as! [String:AnyObject]
		settings = game["Settings"] as! [String : AnyObject]
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
	func done()
	{
		game["Selected Players"] = selectedPlayers as AnyObject?
		saveGame()
		self.dismiss(animated: true, completion: nil)
	}
	override func viewDidLoad() {
//		self.navigationController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(done))
		settings = game["Settings"] as! [String : AnyObject]

		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		updateGame()
		tableView.reloadData()
		self.clearsSelectionOnViewWillAppear = false
		super.viewWillAppear(animated)
		let plrs = game["Players"] as! [String:AnyObject]
		players = plrs["Names"] as! [String]
		players.remove(at: players.index(of: senderPlayer!)!)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	
	
	// MARK: - Table View
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let player = players[indexPath.row]
		let isSelected = selectedPlayers.contains(player)
		if isSelected
		{
			let index = selectedPlayers.index(of: player)
			selectedPlayers.remove(at: index!)
		}
		else
		{
			selectedPlayers.append(player)
		}
		tableView.deselectRow(at: indexPath, animated: true)
		tableView.reloadRows(at: [indexPath], with: .automatic)
	}
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
	return players.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
		let player = players[indexPath.row]
		cell?.textLabel?.text = player
		if (selectedPlayers.contains(player))
		{
			cell?.accessoryType = .checkmark
		}
		return cell!
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return false
	}
	
	
}


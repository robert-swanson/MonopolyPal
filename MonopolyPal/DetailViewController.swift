//
//  DetailViewController.swift
//  MonopolyPal
//
//  Created by Robert Swanson on 7/2/16.
//  Copyright © 2016 Robert Swanson. All rights reserved.
//

import UIKit
import Foundation

class DetailViewController: UITableViewController {
	var template = "Monopoly"
	var game = (PlistManager.sharedInstance.getValueForKey("Game", key: "Game")! as! [String:AnyObject])
	var settings = [String:AnyObject]()

	var Actions: [Action] = []
	var Sections = [Int]()
	
	var senderPlayer: Int?
	var senderPlayerName: String?
	
	//MARK: - Costum
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
	func saveGame ()
	{
		PlistManager.sharedInstance.saveValue("Game", value: game as AnyObject, forKey: "Game")
	}
	
	func getCellNum(_ indexPath: IndexPath) -> Int
	{
		let row = indexPath.row
		let section = indexPath.section
		var actionNum = row
		if (section > 0)
		{
			for i in 0...((section)-1)
			{
				actionNum += Sections[i]
			}
		}
		return actionNum
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
	func actionPlistNamer(_ Name: String) -> Dictionary<String,String>
	{
		let key: Array = ["Name","Icon","Disclosure","EasyAmount"]
		var sec: Int = 0
		var rv = [String:String]()
		var string: String = ""
		for i in Name.characters
		{
			if (i==":")
			{
				rv[key[sec]]=string
				string = ""
				sec += 1
			}
			else
			{
				string = "\(string)\(i)"
			}
			rv[key[sec]]=string
		}
		return rv
	}
	func updateGame ()
	{
		game = PlistManager.sharedInstance.getValueForKey("Game", key: "Game")! as! [String:AnyObject]
		settings = game["Settings"] as! [String : AnyObject]
	}
	
	//MARK: - Configuration
	override func viewDidLoad() {
		settings = game["Settings"] as! [String : AnyObject]
		super.viewDidLoad()
		self.configureView()
	}
	override func viewDidAppear(_ animated: Bool) {
		template = settings["Selected Game"] as! String
	}
	
	func configureView() {
		updateGame()
		let empty: [Action] = []
		Actions = empty
		Sections = ((game["Templates"]! as! [String:AnyObject])[template]! as! [String:AnyObject])["ActionSections"]! as! [Int]
		
		let ss = ((game["Templates"]! as! [String:AnyObject])[template]! as! [String:AnyObject])["Actions"]! as! [String]
		var a = 0
		for i in ss
		{
			let dic = actionPlistNamer(i)
			let Name = dic["Name"]!
			let Icon = dic["Icon"]!
			let d = dic["Disclosure"]!
			let Dis = convertStringToBool(d)!
			//			let Dis: Bool = convertStringToBool(dic["Disclosure"]!)!
			let es = dic["EasyAmount"]
			var easy: Int? = nil
			if es != nil
			{
				easy = Int(es!)!
			}
			//			let es = Int(dic["EasyAmount"]!)
			Actions.append(Action(actionName: Name, iconName: Icon, disclosure: Dis, easyAction: easy, Index:  a))
			a += 1
		}
		tableView.reloadData()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	//	MARK: - TableView
	override func numberOfSections(in tableView: UITableView) -> Int
	{
		return Sections.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Sections[section]
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let actionNum = getCellNum(indexPath)
		
		let Ac: Action = Actions[actionNum]
		let id: String
		if (Ac.disclosure == true)
		{
			id = "action"
		}
		else
		{
			id = "actionW/O"
		}
		let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
		cell.textLabel?.text = Ac.actionName
		cell.imageView?.image = Ac.actionIcon
		if (id == "actionW/O")
		{
			cell.selectionStyle = .blue
			
		}
		return cell
		
	}
	
	//MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if segue.identifier == "ActionDetail" {
			if let indexPath = self.tableView.indexPathForSelectedRow {
				
				let controller = (segue.destination as! UINavigationController).topViewController as! ActionDetailViewController
				let senderA = Actions[getCellNum(indexPath)]
				
				controller.senderAction = 	senderA
				controller.senderPlayer = senderPlayer
				let players = (game["Players"] as! [String:AnyObject])["Names"] as! [String]
				controller.senderPlayerName = players[senderPlayer!]
				controller.senderController = self as UITableViewController
				controller.navigationItem.title = senderA.actionName
				controller.selectedPlayers = []
				var otherP: [String] = []
				if (players.count == 2){
					let i = (senderPlayer! == 0) ? 1 : 0
					let playera = players[i]
					if (players.count == 2) {otherP = [playera]}
				}
				game["Selected Players"] = otherP as AnyObject?
				
				saveGame()
			}
		}
	}
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		updateGame()
		let act = Actions[getCellNum(indexPath)]
		
		if (!act.disclosure)
		{
			
			let amount = act.easyAction!
			
			var players = game["Players"] as! [String:AnyObject]
			let names = players["Names"] as! [String]
			var scores = players["Scores"] as! [Int]
			
			let name = names[senderPlayer!]
			if (senderPlayerName == name)
			{
				scores[senderPlayer!] += amount
				players["Scores"] = scores as AnyObject?
				game["Players"]! = players as AnyObject
				
				var title: String
				if (amount >= 0)
				{
					title = "\(names[senderPlayer!]) recieved \(addUnit(to: amount)) from the bank for: \(act.actionName)"
				}
				else
				{
					title = "\(names[senderPlayer!]) gave \(addUnit(to: amount*(-1))) to the bank for: \(act.actionName)"
				}
				var acts = ""
				acts += "\(amount):"
				acts += (names[senderPlayer!])
				acts += (":Bank")
				var newHist: [String] = []
				newHist.append(title as String)
				newHist.append("\(amount)")
				newHist.append(act.iconID)
				newHist.append(acts)
				var history = game["History"] as! [AnyObject]
				let s = String(history.count)
				newHist.append(s)
				history.append(newHist as AnyObject)
				game["History"] = history as AnyObject?
				saveGame()
			}
			else
			{
				print("ERROR-EasyActionFalure")
			}
			tableView.deselectRow(at: indexPath, animated: true)
		}
	}
	
}


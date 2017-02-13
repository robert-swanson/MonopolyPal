//
//  MasterViewController.swift
//  MonopolyPal
//
//  Created by Robert Swanson on 7/2/16.
//  Copyright © 2016 Robert Swanson. All rights reserved.
//

import UIKit
import Foundation

class HistoryViewController: UITableViewController {
	
	
	// MARK: - Vars
	
	var game = (PlistManager.sharedInstance.getValueForKey("Game", key: "Game")! as! [String:AnyObject])
	var settings = [String:AnyObject]()
	var history: [AnyObject]?
	var orgHistory = [Int:[[String]]]()
	
	var byPlayer: Bool = false
	var orderTopLatest: Bool = true
	var hasBeenInformed: Bool = false
	var cellColor = UIColor()
	var cellT = UIColor()
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

	func fixIDs()
	{
		var a = 0
		for i in history!
		{
			var hist = i as! [String]
			hist[4] = String(a)
			history![a] = hist as AnyObject
			a += 1
		}
	}
	func search(_ forItem:String, inArray: [String]) -> Int?
	{
		var a = 0
		for i in inArray
		{
			if (i == forItem)
			{
				return a
			}
			a += 1
		}
		print("SEARCH FAILED: Item \(forItem) does not exist in array \(inArray)")
		
		if !hasBeenInformed
		{
		let deletedPlayerAlert = UIAlertController(title: "Deleted Player", message: "One or more of the players involved in this transaction have been deleted from the game. All other players' scores have been adjusted correctly.", preferredStyle: .alert)
		deletedPlayerAlert.addAction(UIKit.UIAlertAction(title: "OK", style: .default, handler: nil))
		self.present(deletedPlayerAlert, animated: true, completion: nil)
		hasBeenInformed = true
		}
		return nil
	}
	func getCellNum(_ indexPath: IndexPath) -> Int
	{
		let row = indexPath.row
		let section = indexPath.section
		var actionNum = row
		
		var Sections: [Int] = []
		for i in (0 ..< orgHistory.count)
		{
			Sections.append((orgHistory[i]?.count)!)
		}
		
		if (section > 0)
		{
			for i in 0...((section)-1)
			{
				actionNum += Sections[i]
			}
		}
		return actionNum
	}
	func actionPlistNamer(_ Name: String) -> Dictionary<String,String>
	{
		var sec: Int = 0
		var rv = [String:String]()
		var string: String = ""
		for i in Name.characters
		{
			if (i==":")
			{
				rv["\(sec)"]=string
				string = ""
				sec += 1
			}
			else
			{
				string = "\(string)\(i)"
			}
			rv["\(sec)"]=string
		}
		return rv
	}
	func saveGame ()
	{
		PlistManager.sharedInstance.saveValue("Game", value: game as AnyObject, forKey: "Game")
	}
	
	func updateGame ()
	{
		game = PlistManager.sharedInstance.getValueForKey("Game", key: "Game")! as! [String:AnyObject]
		settings = game["Settings"] as! [String : AnyObject]
	}
	func organizeByPlayer()
	{
		var rv = [Int:[[String]]]()
		let players = game["Players"] as! [String:AnyObject]
		let names = players["Names"] as! [String]
		
		var numbers = [String:Int]()
		var a = 0
		for i in names
		{
			numbers[i] = a
			rv[a] = []
			a += 1
			
		}
		
		for i in history!
		{
			let arr = i as! [String]
			let name = arr[3]
			let info = historyNamer(name)
			let player = info[1]
			if byPlayer {
				rv[numbers[player]!]!.insert(arr, at: 0)}

			else {rv[numbers[player]!]!.append(arr)}
		}
		orgHistory = rv
		
	}
	func historyNamer(_ Name: String) -> [String]
	{
		var sec: Int = 0
		var rv = [String]()
		var string: String = ""
		for i in Name.characters
		{
			if (i==":")
			{
				rv.append(string)
				string = ""
				sec += 1
			}
			else
			{
				string = "\(string)\(i)"
			}
		}
		rv.append(string)
		return rv
	}
	
	// MARK: - Initializer
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		settings = game["Settings"] as! [String : AnyObject]
		self.navigationItem.leftBarButtonItem = self.editButtonItem
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "More"), style: .plain, target: self, action: #selector(organizeAlert))
		customTableColors()
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		updateGame()
		history = (game["History"]! as! NSMutableArray) as [AnyObject]
		let settings = game["Settings"] as! [String:AnyObject]
		byPlayer = ((settings["Organize"] as! String) == "Player") ? true : false
		if byPlayer
		{
			organizeByPlayer()
		}
		
		
		tableView.reloadData()
		self.clearsSelectionOnViewWillAppear = false
		super.viewWillAppear(animated)
		
		tabBarController?.tabBar.items?[1].badgeValue = nil
		game["Badge"] = 0 as AnyObject
		
		saveGame()
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	
	// MARK: - Alerts
	func organizeAlert()
	{
		let moreAlert = UIAlertController(title: "Arrange", message: "How would you like history to be displayed?", preferredStyle: .actionSheet)
		moreAlert.addAction(UIAlertAction(title: "By time", style: .default, handler: ({
			UIAlertAction in
			var settings = self.game["Settings"] as! [String:AnyObject]
			settings["Organize"] = "Time" as AnyObject?
			self.game["Settings"] = settings as AnyObject?
			self.saveGame()
			self.byPlayer = ((settings["Organize"] as! String) == "Player") ? true : false
			if self.byPlayer {
				self.organizeByPlayer()
			}
			self.tableView.reloadData()
		})))
		moreAlert.addAction(UIAlertAction(title: "By player", style: .default, handler: ({
			UIAlertAction in
			var settings = self.game["Settings"] as! [String:AnyObject]
			settings["Organize"] = "Player" as AnyObject?
			self.game["Settings"] = settings as AnyObject?
			self.saveGame()
			self.byPlayer = ((settings["Organize"] as! String) == "Player") ? true : false
			if self.byPlayer {
				self.organizeByPlayer()
			}
			self.tableView.reloadData()
		})))
		moreAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		present(moreAlert, animated: true, completion: nil)
		
	}
	
	
	
	// MARK: - Table View
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if byPlayer
		{
			let players = game["Players"] as! [String:AnyObject]
			let names = players["Names"] as! [String]
			return names[section]
		}
		return ""
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		if (byPlayer)
		{
			updateGame()
			let players = game["Players"] as! [String:AnyObject]
			let names = players["Names"]!
			print("Table has \(names.count) sections.")
			return names.count
		}
		else
		{
			return 1
		}
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		updateGame()
		if byPlayer
		{
		print("Table has \(orgHistory[section]!.count) rows in section \(section).")
			organizeByPlayer()
		return orgHistory[section]!.count
		}
		else
		{
		return history!.count
		}
	}
	

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let label: String
		var ip = indexPath
		if byPlayer
		{
			let hist = orgHistory[indexPath.section]![indexPath.row]
			label = hist[0]
		}
		else
		{
			if orderTopLatest
			{
				ip = IndexPath(row: history!.count - 1 - indexPath.row, section: 0)
			}
			label = (history![ip.row] as! [String]) [0]
		}

		let cellFont = UIFont(name: "Helvetica Neue", size: CGFloat(16.0))
		let max = CGFloat.greatestFiniteMagnitude
		
		let attributedText: NSAttributedString = NSAttributedString(string: (label), attributes: {
			[NSFontAttributeName : cellFont!] as [String:AnyObject]
			}())
		let rect = attributedText.boundingRect(with: CGSize(width: tableView.bounds.width-70, height: max), options: .usesLineFragmentOrigin, context: nil)
		let cellHi = rect.size.height + 20
			return cellHi
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let length = history?.count
		let settings = game["Settings"] as! [String:AnyObject]
		let order = settings["Order"] as! String
		let bool = (order == "true" ? true : false)
		orderTopLatest = bool
		let index: IndexPath
		if (bool)
		{
			index = IndexPath(row: length! - 1 - indexPath.row, section: 0)
		}
		else
		{
			index = indexPath
		}
		let cell = tableView.dequeueReusableCell(withIdentifier: "History", for: indexPath)
		let act: [String]
		if byPlayer
		{
			print (indexPath.section,indexPath.row)
			let playerHist = orgHistory[indexPath.section]
			act = playerHist![indexPath.row]
		}
		else
		{
			act = history![index.row] as! [String]
		}
		//			let act = orgHistory
		
		cell.textLabel?.text = (act[0])
		cell.textLabel?.numberOfLines = 0
		cell.textLabel?.lineBreakMode = .byWordWrapping
		cell.sizeToFit()
		cell.backgroundColor = cellColor
		cell.textLabel?.textColor = cellT
		
		cell.detailTextLabel?.text = (act[1])
		cell.imageView?.image = UIImage(named: act[2])
		return cell
		
		
	}

	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
	}
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			
			let alert = UIAlertController(title: "Confirm Delete", message: "Deleting history will undo the action that it performed. It will also count as an action itself and will appear in the history.", preferredStyle: .alert)
			let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
			let delete = UIAlertAction(title: "Delete", style: .destructive, handler:
				{
					UIAlertAction in
					
					let hist: [String]
					var players = self.game["Players"] as! [String:AnyObject]
					let names = players["Names"] as! [String]
					var scores = players["Scores"] as! [Int]
					
					if self.byPlayer {
						hist = self.orgHistory[indexPath.section]![indexPath.row]
						let index = Int(hist[4])!
						self.history?.remove(at: index)}
					else {
						if self.orderTopLatest
						{
							let index = (self.history!.count - 1) - indexPath.row
							hist = self.history![index] as! [String]
							self.history?.remove(at: index)
						}
						else
						{
							hist = self.history![indexPath.row] as! [String]
							self.history?.remove(at: indexPath.row)}
						}
					self.game["History"] = self.history as AnyObject?
					self.organizeByPlayer()
//					print(((self.game["History"]! as! [AnyObject])[0] as! [String])[0])
					self.tableView.deleteRows(at: [indexPath], with: .fade)
					
					var info = self.historyNamer(hist[3]) as [String]
					let amount = Int(info[0])!
					let player1 = info[1]
					var otherPlayers: [String] = []
					for i in 1...(info.count-2)
					{
						otherPlayers.append(info[i+1])
					}
					
					for i in 1...(otherPlayers.count)
					{
						let s = otherPlayers[i-1]
						let indexP = names.index(of: player1)!
						var pscore = scores[indexP]
						pscore -= amount
						scores[indexP] = pscore
						if (s == "Bank") {break}
						let mult = (i==0) ? -1 : 1
						guard let index = self.search(s, inArray: names) else {break}
						let money = scores[index]
						scores[index] = money + (amount * mult)
					}
					
					var title = hist[0]
					let idx1 = title.characters.index(title.startIndex, offsetBy: 17)
					let idx2 = title.characters.index(title.startIndex, offsetBy: 19)
					let str1 = hist[0].substring(to: idx1)
					let str2 = hist[0].substring(to: idx2)
					if (str1 == "Deleted History: ")
					{let des = title.substring(from: idx1)
					title = "Undeleted History: \(des)"}
					else if (str2 == "Undeleted History: ")
					{let des = title.substring(from: idx2)
						title = "Deleted History: \(des)"}
					else {title = "Deleted History: \(title)"}
					
					info[0] = String(amount*(-1))
					var actions = ""
					var b = 0
					for i in info
					{
					let s = (b < info.count-1) ? ":" : ""
					b += 1
					actions += i + s
					}
					
					var newHist = hist
					newHist[0] = title
					newHist[1] = actions
					newHist[3] = actions
					self.history!.append(newHist as AnyObject)
					self.fixIDs()

					players["Scores"] = scores as AnyObject?
					self.game["Players"] = players as AnyObject?
					self.game["History"] = self.history! as [AnyObject] as AnyObject?
					self.saveGame()
					print (indexPath.section, indexPath.row)
					
					self.game["History"] = self.history as AnyObject?
					self.saveGame()
					if self.orderTopLatest
					{
						self.tableView.insertRows(at: [IndexPath(row: 0, section: indexPath.section)], with: .fade)
					}
					else
					{
						if self.byPlayer
						{
							let row = self.orgHistory[indexPath.section]!.count
							self.tableView.insertRows(at: [IndexPath(row: row, section: indexPath.section)], with: .fade)


						}
						else
						{
							let row = (self.history!.count-1)
							let indexP = IndexPath(row: row, section: indexPath.section)
							print(indexP.section, indexP.row)
							self.tableView.insertRows(at: [indexP], with: .fade)

						}
					}
					
					
//					self.updateGame()
//					self.tableView.reloadData()
			})
			alert.addAction(cancel)
			alert.addAction(delete)
			
			present(alert, animated: true, completion: nil)
		}
	}
	
	
}


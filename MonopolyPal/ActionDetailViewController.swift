//
//  DetailViewController.swift
//  MonopolyPal
//
//  Created by Robert Swanson on 7/2/16.
//  Copyright © 2016 Robert Swanson. All rights reserved.
//

import UIKit
import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
	switch (lhs, rhs) {
	case let (l?, r?):
		return l < r
	case (nil, _?):
		return true
	default:
		return false
	}
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
	switch (lhs, rhs) {
	case let (l?, r?):
		return l > r
	default:
		return rhs < lhs
	}
}


class ActionDetailViewController: UITableViewController {
	var game = (PlistManager.sharedInstance.getValueForKey("Game", key: "Game")! as! [String:AnyObject])
	var settings = [String:AnyObject]()
	var history: [[AnyObject]]?
	var selectedTemplate: String = "Monopoly"
	var Details: [ActionDetail] = []
	var senderAction: Action?
	var senderPlayer: Int?
	var senderPlayerName: String?
	var senderController: UITableViewController? = nil
	
	var selectedPlayers: [String] = []
	var quickAmount: Int?
	var selectedEasy: Int?
	
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
		let key: Array = ["Identifier","Style","Placeholder","Multiplyer", "Value", "Label"]
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
		rv[key[sec]]=string
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
	
	//MARK: - Configuration
	
	override func viewDidLoad() {
		settings = game["Settings"] as! [String : AnyObject]
		tableView.allowsSelection = true
		NotificationCenter.default.addObserver(self, selector: #selector(submitAction), name: NSNotification.Name(rawValue: "SubmitAction"), object: nil)
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(submitAction))
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction))
		super.viewDidLoad()
		self.configureView()
		//		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		//		view.addGestureRecognizer(tap)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		tableView.reloadData()
		updateGame()
		selectedPlayers = game["Selected Players"]! as! [String]
	}
	func dismissKeyboard() {
		//Causes the view (or one of its embedded text fields) to resign the first responder status.
		view.endEditing(true)
	}
	
	
	func configureView() {
		history = (game["History"]! as! [[AnyObject]])
		
		let det = ((game["Templates"]! as! [String:AnyObject])["Monopoly"]! as! [String:AnyObject])["Details"]! as! [String:[String]]
		//		let actions = ((game["Templates"]! as! [String:AnyObject])["Monopoly"]! as! [String:AnyObject])["Actions"]! as! [String]
		let acts = det[senderAction!.actionName]!
		for i in 0..<acts.count
		{
			let dic = actionPlistNamer(acts[i])
			let id = dic["Identifier"]!
			let style = dic["Style"]!
			let ph = dic["Placeholder"]
			let mtplr = dic["Multiplyer"]
			let value = dic["Value"]
			let label = dic["Label"]
			var multiplyer: Double? = nil
			var val: Int? = nil
			if mtplr != nil
			{
				multiplyer = (mtplr! as NSString).doubleValue
			}
			if value != nil
			{
				val = Int(value!)
			}
			
			let detail = ActionDetail(label: label, detailCellIdentifier: id, placeholder: ph, multiplyer: multiplyer, value: val)
			switch style {
			case ".Get":
				detail.style = .get
			case ".Give":
				detail.style = .give
			case ".TradeMode":
				detail.style = .tradeMode
			case ".PlayerPicker":
				detail.style = .playerPicker
			case ".Incrementer":
				detail.style = .incrementer
			default:
				break
			}
			Details.append(detail)
			
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	//	MARK: - TableView
	override func numberOfSections(in tableView: UITableView) -> Int
	{
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Details.count
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		let detail = Details[indexPath.row]
		let old = selectedEasy
		if (detail.detailCellIdentifier == "Easy")
		{
			if (selectedEasy != nil && selectedEasy! == indexPath.row)
			{
				selectedEasy = nil
			}
			else
			{
				selectedEasy = indexPath.row
				quickAmount = detail.value!
			}
			var ips: [IndexPath] = []
			if old != nil {ips.append(IndexPath(row: old!, section: 0))}
			ips.append(indexPath)
			tableView.reloadRows(at: ips, with: .automatic)
		}
		tableView.deselectRow(at: indexPath, animated: true)
		
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let AD: ActionDetail = Details[indexPath.row]
		let id = AD.detailCellIdentifier
		let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
		switch id {
		case "GetVar":
			
			let a = cell as! GetVarCellController
			if (tableView.numberOfRows(inSection: 0)-1 == indexPath.row)
			{
				a.isLast = true
			}
			a.TextField.placeholder = AD.placeholder
			a.TextField.delegate = a
			a.TextField.keyboardType = .numberPad
			
			if (indexPath.row == 0)
			{
				a.TextField.becomeFirstResponder()
			}
			return a
		case "PlayerPicker":
			let a = cell
			var s = ""
			if selectedPlayers.count == 0
			{
				s = ""
			}
			else if selectedPlayers.count == 1
			{
				s = selectedPlayers[0]
			}
			else
			{
				s = "\(selectedPlayers.count) players"
			}
			
			
			a.detailTextLabel?.text = s
			return a
			// Modify a to change player picker cell
			
		case "TradeMode":
			let a = cell as! SegmentedControllCellController
			return a
		case "Easy":
			let a = cell
			a.textLabel?.text = AD.detailLabel
			if (selectedEasy != nil && selectedEasy! == indexPath.row)
			{
				a.accessoryType = .checkmark
			}
			else
			{
				a.accessoryType = .none
			}
			return a
		//Modify a to change trade mode cell
		case "Incrementer":
			let a = cell as! IncrementerCellController
			a.Label.text = AD.detailLabel! + ": 1"
			a.name = AD.detailLabel
			return a
		default:
			print("Other")
			return cell
		}
		
	}
	
	//MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if segue.identifier == "PlayerPicker" {
			if let _ = self.tableView.indexPathForSelectedRow {
				
				let controller = (segue.destination as! UINavigationController).topViewController as! PlayerPickerMenu
				controller.senderPlayer = senderPlayerName
				controller.selectedPlayers = selectedPlayers
				
				
			}
		}
		
	}
	//MARK: - Actions
	
	func submitAction()
	{
		func checkIfListIsComplete(_ checkList: [String:Bool]) -> Bool
		{
			var complete: Bool = true
			var required: [String:Bool] = ["Amount":true,"OtherPlayers":false,"Multiplyer":false]
			for i in Details
			{
				let id = i.detailCellIdentifier
				switch id
				{
				case "GetVar":
					required["Amount"] = true
				case "PlayerPicker":
					required["OtherPlayers"] = true
				case "Easy":
					required["Amount"] = true
				case "Incrementer":
					required["Multiplyer"] = true
				default:
					break
				}
			}
			if (required["Amount"]! && !checkList["Amount"]!) {complete = false}
			if (required["OtherPlayers"]! && !checkList["OtherPlayers"]!) {complete = false}
			if (!complete){
				print("Uncomplete checklist")
			}
			return complete
		}
		func addBadge()
		{
			var current: Int = game["Badge"] as! Int
			current += 1
			senderController!.tabBarController?.tabBar.items?[1].badgeValue = String(current)
			game["Badge"] = current as AnyObject
		}
		
		enum Problem
		{
			case none
			case resetProblem
			case inputError
			case otherPlayerError
			case playerInDebt
		}
		var problem: Problem = .none
		var validSubmit = true
		
		let players = (game["Players"]! as! [String: AnyObject])["Names"]! as! [String]
		guard var Scores = ((game["Players"] as! [String:AnyObject])["Scores"] as? [Int])else {validSubmit = false;return}
		var checklist: [String:Bool] = ["Amount":false,"Player":false, "OtherPlayers":false, "Multiplyer":false]
		
		
		
		var involvesOtherPlayer = false
		
		let b1 = players.count > senderPlayer!
		let b2 = players[senderPlayer!] == senderPlayerName
		if (b1 && b2) {validSubmit = true}
		else{validSubmit = false
			problem = .resetProblem}
		
		var actionAmount: Int?
		var actionOthers: [String]?
		var actionMultiplyer: Double?
		var AmountConflict = 0
		
		var index = -1
		for cellNum in 0..<Details.count
		{
			index += 1
			let cell = tableView.cellForRow(at: IndexPath(row: cellNum, section: 0))
			let detail = Details[cellNum]
			let style = detail.style
			
			switch detail.detailCellIdentifier {
			case "GetVar":
				let varCell = cell as! GetVarCellController
				if let s = varCell.TextField.text{
					if let a = Int(s){
						if checklist["Amount"]! {AmountConflict += 1}
						else {checklist["Amount"] = true
							actionAmount = a}
					}
					else
					{validSubmit = false
						problem = .inputError}
				}
				actionMultiplyer = detail.multiplyer
				
			case "PlayerPicker":
				actionOthers = selectedPlayers
				if actionOthers?.count > 0
				{
					checklist["OtherPlayers"] = true
					involvesOtherPlayer = true
				}
				else{problem = .otherPlayerError}
			case "Easy":
				if checklist["Amount"]! {AmountConflict += 1}
				else {checklist["Amount"] = true}
				
				if (index == selectedEasy && quickAmount != nil)
				{
					actionAmount = quickAmount
					
				}
			case "TradeMode":
				let a = cell as! SegmentedControllCellController
				let mode = a.segmentedControll.selectedSegmentIndex
				let m = (mode == 0) ? 1.0 : -1.0
				if actionMultiplyer == nil {actionMultiplyer = m}
				else {actionMultiplyer! *= m}
			case "Incrementer":
				let c = cell! as! IncrementerCellController
				if (actionMultiplyer != nil) {actionMultiplyer! *= c.Incrementer.value}
				else {actionMultiplyer = c.Incrementer.value}
				
			default:
				print("Unrecognized cell at index \(cellNum)")
			}
			
			switch style {
			case .get?:
				if actionMultiplyer == nil
				{
					actionMultiplyer = 1
				}
			case .give?:
				if actionMultiplyer == nil
				{
					actionMultiplyer = -1
				}
				else
				{
					actionMultiplyer! *= -1
				}
			default:
				break
			}
		}
		
		if (AmountConflict > 0)
		{
			let issue = "Action: \(senderAction) had \(AmountConflict) conflicting amounts"
			var temp = game["Templates"] as! [String:AnyObject]
			var g = temp[selectedTemplate] as! [String:AnyObject]
			var i = g["Issues"] as! [String]
			i.append(issue)
			g["Issues"] = i as AnyObject?
			temp[selectedTemplate] = g as AnyObject?
			game["Templates"] = temp as AnyObject?
			saveGame()
		}
		
		if (!checkIfListIsComplete(checklist))
		{
			validSubmit = false
			
		}
		let settings = game["Settings"] as! [String:AnyObject]
		let seting = settings["Allow Debt"] as! String
		let allow = (seting == "true")
		
		var p = game["Players"] as! [String:AnyObject]
		let n = p["Names"] as! [String]
		var scs = p["Scores"] as! [Int]
		var score = scs[senderPlayer!]
		var debt = 0
		var debtor = ""
		
		if (validSubmit)
		{
			let amount = Int(Double(actionAmount!) * actionMultiplyer!)
			
			if actionOthers != nil{
				let num = score + (amount * actionOthers!.count)
				if num < 0{
					validSubmit = false
					problem = .playerInDebt
					debt = num * -1
				}
				
			}
			else {
				let num = score + amount
				if (num) < 0{
					validSubmit = false
				problem = .playerInDebt
				debt = num * -1
				}
			}
			
			if actionOthers != nil
			{
				for i in actionOthers!
				{
					let index = n.index(of: i)
					score += amount
					if  (!allow && score < 0)
					{
						validSubmit = false
						problem = .playerInDebt
						debt = score * -1
						break
					}
					let hisnum = scs[index!]-amount
					if hisnum < 0{
						validSubmit = false
						problem = .playerInDebt
						debt = hisnum * -1
						debtor = players[index!]
					}
					else{
						scs[index!] = hisnum
					}
				}
			}
			else
			{
				score += amount
			}
			if validSubmit
			{
				scs[senderPlayer!] = score
				p["Scores"] = scs as AnyObject?
				game["Players"] = p as AnyObject?
				
				var title = ""
				var actions = ""
				var nameOfOtherPeople = ""
				actions += ("\(amount):")
				actions += (players[senderPlayer!])
				if involvesOtherPlayer {
					let num = actionOthers!.count
					var a = 1
					for i in actionOthers!{
						actions += ":\(i)"
						if (a == 1) {nameOfOtherPeople += i}
						else if (a == num) {nameOfOtherPeople += ", and \(i)"}
						else if (a > 1 && a < num) {nameOfOtherPeople += ", \(i)"}
						a += 1
					}
				}
				else {actions += (":Bank")
					nameOfOtherPeople = "the Bank"
					
				}
				
				let reason = senderAction!.actionName
				let verb = (amount > 0) ? " recieved " : " gave "
				let word = (amount > 0) ? " from " : " to "
				let unit = (amount > 0) ? "\(addUnit(to: amount))" : "\(addUnit(to: amount*(-1)))"
				title = senderPlayerName! + verb + unit + word
				title += nameOfOtherPeople + " for: " + reason
				
				var newHist: [String] = []
				newHist.append(title as String)
				newHist.append("\(amount)" as String)
				newHist.append(senderAction!.iconID)
				newHist.append(actions)
				let s = String(history!.count)
				newHist.append(s)
				
				Scores[senderPlayer!] += amount
				
				history?.append(newHist as [AnyObject])
				game["History"] = history as AnyObject?
				self.game["Selected Players"] = [] as AnyObject
				
				addBadge()
				saveGame()
				self.dismiss(animated: true, completion: nil)
			}
		}
		if (problem == .inputError)
		{
			let alert = UIAlertController(title: "Input Error", message: "One or more of the values you Inserted were empty or invalid. Remember that you can only insert numbers into text fields.🙄", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
			//			showViewController(alert, sender: self)
			present(alert, animated: true, completion: nil)
			
		}
		if (problem == .resetProblem)
		{
			let alert = UIAlertController(title: "Reset Error", message: "There was an error finding the specified player: \(senderPlayerName!). Have you recently reset the game? Try going back to the player menu before continuing.🙂", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
			//			showViewController(alert, sender: self)
			present(alert, animated: true, completion: nil)
		}
		if (problem == .otherPlayerError)
		{
			let alert = UIAlertController(title: "Player Error", message: "You have not selected any players yet. Choose one and press done to continue.😡", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
			present(alert, animated: true, completion: nil)
		}
		if (problem == .playerInDebt)
		{
			let message = (debtor == "") ? "You are short " : debtor + " is short "
			let alert = UIAlertController(title: "Debt Error", message: "Your settings do not allow any players to go into debt. \(message) \(addUnit(to: debt)). Sorry 😐.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
			present(alert, animated: true, completion: nil)
		}
		if (problem == .none)
		{
			let alert = UIAlertController(title: "Action Error", message: "There was an unknown error when trying to perform this action.⁉️", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
			present(alert, animated: true, completion: nil)
		}
		
		
	}
	func cancelAction()
	{
		self.dismiss(animated: true, completion: nil)
		
	}
	//MARK: - Cells
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		resignFirstResponder()
	}
	
}


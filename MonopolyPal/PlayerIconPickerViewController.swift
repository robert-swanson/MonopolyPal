//
//  PlayerIconPickerViewController.swift
//  MonopolyPal
//
//  Created by Robert Swanson on 2/24/17.
//  Copyright © 2017 Robert Swanson. All rights reserved.
//

import Foundation
import UIKit

class PlayerIconPickerViewController: UITableViewController {
	//MARK: Vars
	var game = (PlistManager.sharedInstance.getValueForKey("Game", key: "Game")! as! [String:AnyObject])
//	var playersWFP: [Player] = Array()
	var playersWOFP: [Player] = Array()
	var pieces: [Piece] = Array()
	var sender: Int? = nil
	var freeParking = false
	var fpName = ""
	var fpScore = 0
	
	//Mark: - Costum
	
	
	//MARK: - Initialize
	override func viewDidLoad() {
		//TODO: Initialize View
		updateGame()
		initPlayers()
		initPieces()
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(done))
		
		super.viewDidLoad()
	}
	
	//MARK: - File
	func initPlayers(){
		var p = game["Players"] as! [String:AnyObject]
		var Names = p["Names"] as! [String]
		var Scores = p["Scores"] as! [Int]
		var icons = p["Icons"] as! [String:String]
		var a = 0
		for name in Names{
			var image: UIImage? = nil
			var s: String?
			if let icon = icons[name]{
				image = UIImage(named: icon)
				s = icon
			}
			let player = Player(PlayerName: Names[a], Score: Scores[a], Icon: image, imagePath: s)
			if !player.name.lowercased().contains("free parking"){
				playersWOFP.append(player)
			}
			else{
				freeParking = true
				fpName = player.name
				fpScore = player.score
			}
//			playersWFP.append(player)
			a += 1
		}
	}
	func initPieces(){
		pieces.removeAll()
		let icons = ["Battleship","Cannon","Car","Cat","Dog","Hat","Horse","Iron","Money","Shoe","Thimble","Wheelbarrow"]
		for icon in icons{
			pieces.append(Piece(icon: UIImage(named:icon)!, title: icon))
		}
	}
	
	func done(){
		// TODO: Done
		self.dismiss(animated: true, completion: nil)
	}
	func saveGame ()
	{
		var p = game["Players"] as! [String:AnyObject]
		var names: [String] = Array()
		var scores: [Int] = Array()
		var icons: [String:String] = Dictionary()
		for player in playersWOFP{
			names.append(player.name)
			scores.append(player.score)
			if let icon = player.imagePath{
				icons[player.name] = icon
			}
		}
		if freeParking{
			names.append(fpName)
			scores.append(fpScore)
		}
		p["Names"] = names as AnyObject
		p["Scores"] = scores as AnyObject
		p["Icons"] = icons as AnyObject
		game["Players"] = p as AnyObject
		PlistManager.sharedInstance.saveValue("Game", value: game as AnyObject, forKey: "Game")
	}
	func updateGame ()
	{
		game = PlistManager.sharedInstance.getValueForKey("Game", key: "Game")! as! [String:AnyObject]
	}
	
//	MARK: - TableView
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1;
	}
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return pieces.count
	}
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
		cell?.backgroundColor = UIColor(red: 232, green: 232, blue: 232)
		cell?.textLabel?.text = pieces[indexPath.row].Title
		cell?.imageView?.image = pieces[indexPath.row].Icon
		return cell!
	}
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		playersWOFP[sender!].imagePath = pieces[indexPath.row].Title
		playersWOFP[sender!].icon = pieces[indexPath.row].Icon
		saveGame()
		done()
	}
}

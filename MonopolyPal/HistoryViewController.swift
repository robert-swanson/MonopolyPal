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
	var history: [History]?
	
	
	// MARK:- Custom
	func actionPlistNamer(Name: String) -> Dictionary<String,String>
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
		PlistManager.sharedInstance.saveValue("Game", value: game, forKey: "Game")
	}
	
	func updateGame ()
	{
		game = PlistManager.sharedInstance.getValueForKey("Game", key: "Game")! as! [String:AnyObject]
	}
	// MARK: - Initializer
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		self.navigationItem.leftBarButtonItem = self.editButtonItem()
		
		
	}
	override func viewWillAppear(animated: Bool) {
		updateGame()
//		let a = game["History"]!
		history = (game["History"]! as! [History])
//		history! = game["History"] as! [History]
		
		tableView.reloadData()
		self.clearsSelectionOnViewWillAppear = false
		super.viewWillAppear(animated)
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	
	// MARK: - Alerts
	
	
	// MARK: - Table View
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return history!.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("History", forIndexPath: indexPath)
		let act = history![indexPath.row]
		cell.textLabel?.text! = act.title
		cell.detailTextLabel?.text = String(act.amount)
		cell.imageView?.image = act.icon
		
		return cell
	}
	func deleteAt(indexPath: NSIndexPath)
	{
		
		
	}
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
	}
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
			
			let alert = UIAlertController(title: "Confirm Delete", message: "Deleting history will undo the action that it performed. It will also count as an action itself and will appear in the history.", preferredStyle: .Alert)
			let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
			let delete = UIAlertAction(title: "Delete", style: .Default, handler:
				{
					UIAlertAction in
					tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
					self.history?.removeAtIndex(indexPath.row)
					self.game["History"] = self.history! as [AnyObject]
					self.saveGame()
			})
			alert.addAction(cancel)
			alert.addAction(delete)
			
			presentViewController(alert, animated: true, completion: nil)
		}
	}
	
	
}


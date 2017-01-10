//
//  ThemeEditViewController.swift
//  MonopolyPal
//
//  Created by Robert Swanson on 1/5/17.
//  Copyright © 2017 Robert Swanson. All rights reserved.
//


import Foundation
import UIKit
extension UIColor
{
	func isLight() -> Bool
	{
		let components = self.cgColor.components
		
		let a = ((components?[0])! * 299)
		let b = ((components?[1])! * 587)
		let c = ((components?[2])! * 114)
		let brightness = (a+b+c) / 1000
		if brightness < 0.5 {
			return false
		}
		else {
			return true
		}
	}
}

class ThemeEditViewController: UITableViewController {
	
	// MARK: - Vars
	var game = (PlistManager.sharedInstance.getValueForKey("Game", key: "Game")! as! [String:AnyObject])
	var settings = [String:AnyObject]()
	var themes = [String:[String:String]]()
	var theme = [String:String]()
	var this = ""
	var properties = ["Titles","Top Bar","Bottom Bar", "Bar Buttons","Background","Cells","Cell Text","Unselcted Bar Buttons","Selected Bar Buttons"]
	
	// MARK:- Custom
	func getColor(fromString: String)-> UIColor{
		let comp = fromString.components(separatedBy: ",")
		return UIColor(red: Int(comp[0])!, green: Int(comp[1])!, blue: Int(comp[2])!)
	}
	/*
	func contrastColor(color: UIColor) -> UIColor {
	var d = CGFloat(0)
	
	var r = CGFloat(0)
	var g = CGFloat(0)
	var b = CGFloat(0)
	var a = CGFloat(0)
	
	color.getRed(&r, green: &g, blue: &b, alpha: &a)
	
	// Counting the perceptive luminance - human eye favors green color...
	let luminance = 1 - ((0.299 * r) + (0.587 * g) + (0.114 * b)) / 255
	
	if luminance < 0.5 {
	d = CGFloat(0) // bright colors - black font
	} else {
	d = CGFloat(255) // dark colors - white font
	}
	
	return UIColor( red: d, green: d, blue: d, alpha: a)
	}
	*/
	func done(){
		self.dismiss(animated: true, completion: nil)
		saveGame()
	}
	func saveGame ()
	{
		themes[this] = theme
		settings["Themes"] = themes as AnyObject
		game["Settings"] = settings as AnyObject
		PlistManager.sharedInstance.saveValue("Game", value: game as AnyObject, forKey: "Game")
	}
	
	func updateGame ()
	{
		game = PlistManager.sharedInstance.getValueForKey("Game", key: "Game")! as! [String:AnyObject]
		settings = game["Settings"] as! [String : AnyObject]
		themes = settings["Themes"] as! [String : [String : String]]
		theme = themes[this]!
	}
	
	// MARK: - Initializer
	
	override func viewDidLoad() {
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
		updateGame()
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
	func changeAlert(property: String){
		func stringColor(from: String) -> String{
			let compp = from.components(separatedBy: ".")
			if (compp.count == 3){
				return compp[0] + "," + compp[1] + "," + compp[2]
			}
			else{
				return "ERROR"
			}
		}
		let alert = UIAlertController(title: "Change \(property)", message: "Type in the RGB value (comma or space seperated) of the color you would like to set.", preferredStyle: .alert)
		let okAction = UIAlertAction(title: "OK",
		                             style: .default,
		                             handler:
			{
				UIAlertAction in
				
				let color = alert.textFields![0].text!
				let s = stringColor(from: color)
				if s == "ERROR" {
					self.error(input: color)
					return
				}
				self.theme[property] = s
				self.saveGame()
				self.tableView.reloadData()
				
		}
		)
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		alert.addAction(okAction)
		alert.addAction(cancelAction)
		alert.addTextField { (textF) in
			textF.placeholder = "Enter RGB"
			textF.keyboardType = .decimalPad
		}
		present(alert, animated: true, completion: nil)
		
		
	}
	func error(input: String){
		let alert = UIAlertController(title: "Input Error", message: "The Inputed value could not be interpreted as a color.", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
		present(alert, animated: true, completion: nil)
	}
	
	func resetGame()
	{
		guard let path = Bundle.main.path(forResource: "Game", ofType: "plist") else { return }
		
		let newGame = NSDictionary(contentsOfFile: path)!
		
		
		PlistManager.sharedInstance.saveValue("Game", value: newGame["Game"] as! [String:AnyObject] as AnyObject, forKey: "Game")
	}
	
	// MARK: - Table View
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		changeAlert(property: properties[indexPath.row])
		tableView.deselectRow(at: indexPath, animated: true)
		tableView.reloadData()
	}
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return properties.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
		let name = properties[indexPath.row]
		let value = getColor(fromString: theme[name]!)
		cell?.textLabel?.text = name
		cell?.backgroundColor = value
		cell?.textLabel?.textColor = value.isLight() ? UIColor.black : UIColor.white
		return cell!
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return false
	}
	
	
}


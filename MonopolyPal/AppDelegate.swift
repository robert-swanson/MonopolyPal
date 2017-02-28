
//  AppDelegate.swift
//  MonopolyPal
//
//  Created by Robert Swanson on 7/2/16.
//  Copyright © 2016 Robert Swanson. All rights reserved.
//

import UIKit
public extension UIImage {
	public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
		let rect = CGRect(origin: .zero, size: size)
		UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
		color.setFill()
		UIRectFill(rect)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		guard let cgImage = image?.cgImage else { return nil }
		self.init(cgImage: cgImage)
	}
}
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
	
	var window: UIWindow?
	var game = (PlistManager.sharedInstance.getValueForKey("Game", key: "Game")! as! [String:AnyObject])
	//	let rootViewControll: UIViewController = self.window!.rootViewController
	// MARK: - Costum
	
	func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
		let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
		let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
		let blue = CGFloat(rgbValue & 0xFF)/256.0
		
		return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
	}
	
	// rbgValue - define hex color value
	// alpha - define transparency value
	// returns - CGColor
	
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		//		let splitViewController = self.window!.rootViewController as! UISplitViewController
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
//		let splitViewController = storyboard.instantiateViewController(withIdentifier: "splitview") as! UISplitViewController
//		let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
//		navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
//		splitViewController.delegate = self
		
		
		
		PlistManager.sharedInstance.startPlistManager("Game")
		UIApplication.shared.statusBarStyle = .lightContent
		
		//Navigation Bar Custimization
		//		var navigationBarAppearace = UINavigationBar.appearance()
		//
		//		navigationBarAppearace.tintColor = UIColorFromHex(rgbValue: 0xff0000)
		//		navigationBarAppearace.barTintColor = UIColorFromHex(rgbValue: 0xffffff)
		// Set navigation bar tint / background colour
		
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
		
		
		var game = PlistManager.sharedInstance.getValueForKey("Game", key: "Game")! as! [String:AnyObject]
		var settings = game["Settings"] as! [String:AnyObject]
		let themes = settings["Themes"] as! [String:[String:String]]
		let selected = settings["Selected Theme"] as! String
		let colors: [String:String]
		if (themes[selected] != nil){
			colors = themes[selected]!
		}
		else{
			colors = themes["Basic Monopoly"]!
			print("No selected theme, choosing default")
		}
		
		// Override point for customization after application launch.
		// Sets background to a blank/empty image
//		let c: UIColor = UIColor.red
//		let i = UIImage(color: c)
//		UINavigationBar.appearance().setBackgroundImage(i, for: .default)
//		// Sets shadow (line below the bar) to a blank image
//		UINavigationBar.appearance().shadowImage = UIImage()
//		// Sets the translucent background color
//		UINavigationBar.appearance().backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
//		// Set translucent. (Default value is already true, so this can be removed if desired.)
//		UINavigationBar.appearance().isTranslucent = true
		
		
		UINavigationBar.appearance().barTintColor = getColor(fromString: colors["Top Bar"]!)
		
		// Set Navigation bar Title colour
		UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: getColor(fromString: colors["Titles"]!)]
		
		// Set navigation bar ItemButton tint colour
		UIBarButtonItem.appearance().tintColor = getColor(fromString: colors["Bar Buttons"]!)
		
		UITabBar.appearance().barTintColor = getColor(fromString: colors["Top Bar"]!)
		UITabBar.appearance().tintColor = getColor(fromString: colors["Selected Bar Buttons"]!);	UITabBar.appearance().unselectedItemTintColor = getColor(fromString: colors["Unselcted Bar Buttons"]!)
		
		UIApplication.shared.statusBarStyle = .lightContent

		print("App Successfully Started")
		return true
	}
	
	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}
	
	func applicationDidEnterBackground(_ application: UIApplication) {
		UIApplication.shared.isIdleTimerDisabled = false
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}
	
	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}
	
	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}
	
	func applicationWillTerminate(_ application: UIApplication) {
		UIApplication.shared.isIdleTimerDisabled = false
		PlistManager.sharedInstance.saveValue("Games", value: game as AnyObject, forKey: "Game")
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
	
	// MARK: - Split view
	
//	func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool
//	{
//		guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
//		guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
//		if topAsDetailController.convertStringToBool("") == nil {
//			// Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
//			return true
//		}
//		return false
//	}
	
}


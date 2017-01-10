//
//  Action.swift
//  MonopolyPal
//
//  Created by Robert Swanson on 7/6/16.
//  Copyright © 2016 Robert Swanson. All rights reserved.
//

import Foundation
import UIKit
class Action: NSObject
{
	let actionName: String
	let actionIcon: UIImage
	let disclosure: Bool
	let easyAction: Int?
	let actionIndex: Int?
//	let addSub: Int?
	let iconID: String
	init(actionName:String, iconName:String, disclosure:Bool, easyAction: Int?, Index: Int?) {
		self.actionName = actionName
		self.actionIcon = UIImage(named: iconName)!
		self.iconID = iconName
		self.disclosure = disclosure
		self.easyAction = easyAction
		self.actionIndex = Index
//		self.addSub = addSub
	}
	convenience init(actionName:String, iconName:String, Index: Int?) {
		self.init(actionName: actionName, iconName: iconName, disclosure: false, easyAction: 0, Index: Index)
	}
}
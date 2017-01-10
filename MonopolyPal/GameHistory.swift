//
//  History.swift
//  MonopolyPal
//
//  Created by Robert Swanson on 7/25/16.
//  Copyright © 2016 Robert Swanson. All rights reserved.
//
import UIKit
import Foundation

class History: NSObject
{
	let title: String
	let amount: Int
	let icon: UIImage
	let actions: [String]
	
	init(title: String, amount: Int, icon: UIImage, actions: [String]) {
		self.title = title
		self.amount = amount
		self.icon = icon
		self.actions = actions
	}
}

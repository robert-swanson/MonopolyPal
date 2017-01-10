//
//  ActionDetail.swift
//  MonopolyPal
//
//  Created by Robert Swanson on 7/21/16.
//  Copyright © 2016 Robert Swanson. All rights reserved.
//

import Foundation

class ActionDetail: NSObject
{
	let detailLabel: String?
	let detailCellIdentifier: String
	var style: ScoreStyle?
	let placeholder: String?
	let multiplyer: Double?
	let value: Int?
	
	enum ScoreStyle {
		case get
		case give
		case amount
		case giveToPlayer
		case playerPicker
		case tradeMode
		case playerPickerView
		case easyAction
		case incrementer
	}
	
	init(label: String?, detailCellIdentifier: String, style: ScoreStyle?, placeholder: String?, multiplyer: Double?, value: Int?) {
//		self.detailName = detailName
		self.placeholder = placeholder
		self.detailCellIdentifier = detailCellIdentifier
		self.style = style
		self.multiplyer = multiplyer
		self.value = value
		self.detailLabel = label
	}
	convenience init(label: String?, detailCellIdentifier: String, placeholder: String?, multiplyer: Double?, value: Int?) {
		self.init(label: label, detailCellIdentifier: detailCellIdentifier,style: nil, placeholder: placeholder, multiplyer: multiplyer, value: value)
	}

}

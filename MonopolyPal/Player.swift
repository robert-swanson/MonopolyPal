//
//  Player.swift
//  MonopolyPal
//
//  Created by Robert Swanson on 7/3/16.
//  Copyright © 2016 Robert Swanson. All rights reserved.
//

import Foundation

class Player: NSObject
{
	var name: String
	var score: Int = 2000
	
	
	init(PlayerName: String, Score: Int) {
		self.name = PlayerName
		self.score = Score
	}
	convenience init(PlayerName: String) {
		self.init(PlayerName: PlayerName, Score: 2000)
	}
}
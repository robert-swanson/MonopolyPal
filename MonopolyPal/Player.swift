//
//  Player.swift
//  MonopolyPal
//
//  Created by Robert Swanson on 7/3/16.
//  Copyright © 2016 Robert Swanson. All rights reserved.
//

import Foundation
import UIKit

class Player: NSObject
{
	var name: String
	var score: Int = 2000
	var icon: UIImage?
	var imagePath: String?
	
	init(PlayerName: String, Score: Int, Icon: UIImage?, imagePath: String?){
		self.name = PlayerName
		self.score = Score
		self.icon = Icon
		self.imagePath = imagePath

	}
	convenience init(PlayerName: String, Score: Int) {
		self.init(PlayerName: PlayerName, Score: Score, Icon: nil, imagePath: nil)
	}
	convenience init(PlayerName: String) {
		self.init(PlayerName: PlayerName, Score: 2000)
	}
}

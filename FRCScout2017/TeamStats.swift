//
//  TeamStats.swift
//  FRCScout2017
//
//  Created by Sharon Kass on 2/19/17.
//  Copyright © 2017 RoboTigers. All rights reserved.
//

import UIKit

class TeamStats {
    
    var teamNumber: String = ""
    
    var numberOfMatchesPlayed: Int = 0
    var avergeNumberFuelLow: Double = 0.0
    var averageNumberFuelHigh: Double = 0.0
    var averageNumberGears: Double = 0.0
    var averageNumberClimbs: Double = 0.0
    var averageNumberAutoScore: Double = 0.0
    var averageNumberTeleScore: Double = 0.0
    
    var totalNumberFuelLow: Int16 = 0
    var totalNumberFuelHigh: Int16 = 0
    var totalNumberGears: Int16 = 0
    var totalNumberClimbs: Int16 = 0
    var totalNumberAutoScore: Int16 = 0
    var totalNumberTeleScore: Int16 = 0
    
    var numberWins: Int = 0
    var numberLoses: Int = 0
    var numberTies: Int = 0
    
    var winningPercentage: Double = 0.0

}

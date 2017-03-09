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
    var averageWeightedDefensePlayedAndEffective: Double = 0.0
    var averagePenalty: Double = 0.0
    
    var totalNumberFuelLow: Int16 = 0
    var totalNumberFuelHigh: Int16 = 0
    var totalNumberGears: Int16 = 0
    var totalNumberClimbs: Int16 = 0
    var totalWeightedDefensePlayedAndEffective: Int16 = 0
    var totalPenalty: Int16 = 0
    var totalFuelFromHopper: Int16 = 0
    var totalFuelFromFeeder: Int16 = 0
    var totalFuelFromFloor: Int16 = 0
    var totalGearsFromHopper: Int16 = 0
    var totalGearsFromFeeder: Int16 = 0
    var totalGearsFromFloor: Int16 = 0
    var totalShootLocations: Int16 = 0
    
    var numberWins: Int = 0
    var numberLoses: Int = 0
    var numberTies: Int = 0
    
    var winningPercentage: Double = 0.0
    
    var penalties: Int16 = 0
    var fuelFromTheHopper: Int16 = 0
    var fuelFromTheFeeder: Int16 = 0
    var fuelFromTheFloor: Int16 = 0
    var gearsFromTheHopper: Int16 = 0
    var gearsFromTheFeeder: Int16 = 0
    var gearsFromTheFloor: Int16 = 0
    var shootLocation: Int16 = 0

}

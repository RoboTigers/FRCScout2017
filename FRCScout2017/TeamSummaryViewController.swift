//
//  TeamSummaryViewController.swift
//  FRCScout2017
//
//  Created by Sabrina Chen on 2/19/17.
//  Copyright © 2017 RoboTigers. All rights reserved.
//

import UIKit
import CoreData

class TeamSummaryViewController: UIViewController{
    
//UIPickerViewDelegate, UIPickerViewDataSource {

    var selectedDriveTrainType = ""
    var existingPitReport : PitReport?
    
    let driveTrainTypes = ["Tank", "H Drive", "Omni", "Halo", "Arcade"]
    var selectedTeamNumber = ""
    
    @IBOutlet weak var teamNum: UILabel!
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var driveCoachName: UILabel!
    @IBOutlet weak var driveTrainsType: UILabel!
    @IBOutlet weak var motorType: UILabel!
    @IBOutlet weak var motorNumber: UILabel!
    @IBOutlet weak var overallSpeed: UILabel!
    @IBOutlet weak var robotWeightt: UILabel!
    @IBOutlet weak var cheesecake: UILabel!
    @IBOutlet weak var storageVolume: UILabel!
    @IBOutlet weak var selectTournamentControl: UISegmentedControl!
    
   
    override func viewDidLoad() {
        print("In viewDidLoad of summary scene")
        print("selected team is \(selectedTeamNumber)")
        super.viewDidLoad()
        var summary = fillTeamStats()
        var pitReports: [PitReport] = []
        CoreDataStack.defaultStack.syncWithCompletion(nil)
        let fetchRequest = NSFetchRequest<PitReport>(entityName: "PitReport")
        fetchRequest.predicate = NSPredicate(format: "teamNumber == \(selectedTeamNumber)")
        do {
            pitReports = try CoreDataStack.defaultStack.managedObjectContext.fetch(fetchRequest)
            if pitReports.count > 0 {
                let existingPitReport = pitReports[0]
                contactName.text = existingPitReport.contactName
                driveCoachName.text = existingPitReport.driveCoach
                driveTrainsType.text = existingPitReport.driveTrainType
                //motorType.text =
                motorNumber.text = NSNumber(value: (existingPitReport.driveTrainMotorNum)).stringValue
                robotWeightt.text = NSNumber(value: (existingPitReport.robotWeight)).stringValue
                storageVolume.text = NSNumber(value: (existingPitReport.estimatedStorageVolumne)).stringValue 

                
                
                
            }
            }catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return driveTrainTypes.count
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return driveTrainTypes[row]
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            selectedDriveTrainType = driveTrainTypes[row]
            title = driveTrainTypes[row]
        }
    }

    func fillTeamStats() -> TeamStats {
        // We will read all the match data into the matches array and then fill a
        // TeamStats object, aggregating the data as we go.
        var matches: [MatchReport] = []
        let summary: TeamStats = TeamStats()
        
        // Query database for all match data for the selected team
        CoreDataStack.defaultStack.syncWithCompletion(nil)
        let fetchRequest = NSFetchRequest<MatchReport>(entityName: "MatchReport")
        fetchRequest.predicate = NSPredicate(format: "teamNumber == \(selectedTeamNumber)")
            do {
            matches = try CoreDataStack.defaultStack.managedObjectContext.fetch(fetchRequest)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        // As we loop through each match we add the match numbers to the totals of the summary 
        // and we calculate the average per match. When we are done with this loop we will have
        // all totals and averages for the team.
        for match in matches {
            summary.numberOfMatchesPlayed = summary.numberOfMatchesPlayed + 1
            summary.totalNumberFuelLow =  summary.totalNumberFuelLow + match.fuelLow
            summary.totalNumberFuelHigh = summary.totalNumberFuelHigh + match.fuelHigh
            summary.totalNumberGears = summary.totalNumberGears + match.gears
            if match.hang {
                summary.totalNumberClimbs = summary.totalNumberClimbs + 1
            }
            summary.avergeNumberFuelLow = Double(summary.totalNumberFuelLow) / Double(summary.numberOfMatchesPlayed)
            summary.averageNumberFuelHigh = Double(summary.totalNumberFuelHigh) / Double(summary.numberOfMatchesPlayed)
            summary.averageNumberGears = Double(summary.totalNumberGears) / Double(summary.numberOfMatchesPlayed)
            summary.averageNumberClimbs = Double(summary.totalNumberClimbs) / Double(summary.numberOfMatchesPlayed)
            switch(match.matchResult) {
            case 0:
                summary.numberWins = summary.numberWins + 1
                break
            case 1:
                summary.numberLoses = summary.numberLoses + 1
                break
            case 2:
                summary.numberTies = summary.numberTies + 1
                break
            default:
                print("No match result, should never reach this!")
                break
            }
        }
        return summary
    }
    
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

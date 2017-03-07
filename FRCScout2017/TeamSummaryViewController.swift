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
    


    var selectedDriveTrainType = ""
    var existingPitReport : PitReport?
    
    let driveTrainTypes = ["Tank", "H Drive", "Omni", "Halo", "Arcade"]
    var selectedTeamNumber = ""
    var selectedTournament = Int16(0)
    
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
    @IBOutlet weak var matchedPlayedOutlet: UILabel!
    @IBOutlet weak var matchesWon: UILabel!
    @IBOutlet weak var matchesLost: UILabel!
    @IBOutlet weak var matchesTied: UILabel!
    @IBOutlet weak var avgGears: UILabel!
    @IBOutlet weak var avgHighFuel: UILabel!
    @IBOutlet weak var avgClimbRate: UILabel!
    @IBOutlet weak var avgClimbSpeed: UILabel!
    @IBOutlet weak var avgLowFuel: UILabel!
    @IBOutlet weak var avgAutoScore: UILabel!
    @IBOutlet weak var avgTeleScore: UILabel!
    @IBOutlet weak var successfulClimbs: UILabel!
    @IBOutlet weak var allComments: UILabel!
    @IBOutlet weak var myImageView: UIImageView!
   
    @IBAction func selectedTournament(_ sender: UISegmentedControl) {
        view.setNeedsDisplay()
        view.reloadInputViews()
        selectedTournament = Int16(sender.selectedSegmentIndex)
        fillScreenComponents()
    }
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = self.view.frame
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
    }
    
    func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }
    func fillScreenComponents() {
        // Fill Match data
        let summary = fillTeamStats()
        print("num is \(summary.numberOfMatchesPlayed)")
        print("string is \(NSNumber(value: summary.numberOfMatchesPlayed).stringValue)")
        matchedPlayedOutlet.text = NSNumber(value: summary.numberOfMatchesPlayed).stringValue
        matchesWon.text = NSNumber(value: summary.numberWins).stringValue
        matchesLost.text = NSNumber(value: summary.numberLoses).stringValue
        matchesTied.text = NSNumber(value: summary.numberTies).stringValue
        let formattedGears = String(format: "%.1f", summary.averageNumberGears)
        avgGears.text = formattedGears
        let formattedHighFuel = String(format: "%.1f", summary.averageNumberFuelHigh)
        avgHighFuel.text = formattedHighFuel
        let formattedLowFuel = String(format: "%.1f", summary.avergeNumberFuelLow)
        avgLowFuel.text = formattedLowFuel
        //avgClimbRate
        //avgClimbSpeed
        successfulClimbs.text = NSNumber(value: summary.totalNumberClimbs).stringValue
        

        
        
        // Fill pit report data
        var pitReports: [PitReport] = []
        //CoreDataStack.defaultStack.sncWithCompletion(nil)
        let fetchRequest = NSFetchRequest<PitReport>(entityName: "PitReport")
        fetchRequest.predicate = NSPredicate(format: "teamNumber == \(selectedTeamNumber)")
        do {
            pitReports = try CoreDataStack.defaultStack.managedObjectContext.fetch(fetchRequest)
            if pitReports.count > 0 {
                let existingPitReport = pitReports[0]
                contactName.text = existingPitReport.contactName
                driveCoachName.text = existingPitReport.driveCoach
                driveTrainsType.text = existingPitReport.driveTrainType
                if existingPitReport.driveTrainMotorType ==  0 {
                    motorType.text = "CIM"
                } else {
                    motorType.text = "Other"
                }
                motorNumber.text = NSNumber(value: (existingPitReport.driveTrainMotorNum)).stringValue
                robotWeightt.text = NSNumber(value: (existingPitReport.robotWeight)).stringValue
                storageVolume.text = NSNumber(value: (existingPitReport.estimatedStorageVolumne)).stringValue
                if existingPitReport.robotWeight<105 {
                    cheesecake.text = "Yes"
                }else {
                    cheesecake.text = "No"
                }
                //105 just to be safe since our component will be around 10-12 lb
                allComments.text = existingPitReport.commentsProud! + existingPitReport.commentsStillWorkingOn!
                if existingPitReport.robotImage != nil {
                let existingImage = UIImage(data: (existingPitReport.robotImage)! as Data)
                myImageView.image = existingImage
                    myImageView.contentMode = .scaleAspectFit
                }
            }
            
    
            
        }catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("In viewWillAppear of summary scene")
        title = "Team \(selectedTeamNumber) Summary"
        fillScreenComponents()
    }

    
    override func viewDidLoad() {
        print("In viewDidLoad of summary scene")
        super.viewDidLoad()
        fillScreenComponents()
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

    func fillTeamStats() -> TeamStats {
        print("Inside fillTeamStats")
        // We will read all the match data into the matches array and then fill a
        // TeamStats object, aggregating the data as we go.
        var matches: [MatchReport] = []
        let summary: TeamStats = TeamStats()
        
        // Query database for all match data for the selected team
        CoreDataStack.defaultStack.syncWithCompletion(nil)
        let fetchRequest = NSFetchRequest<MatchReport>(entityName: "MatchReport")
        fetchRequest.predicate = NSPredicate(format: "teamNumber == \(selectedTeamNumber) AND tournament == \(selectedTournament)")
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
    

}

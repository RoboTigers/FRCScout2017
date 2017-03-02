//
//  ViewController.swift
//  FRCScout2017
//
//  Created by Sharon Kass on 2/5/17.
//  Copyright © 2017 RoboTigers. All rights reserved.
//

import UIKit
import MessageUI
import CoreData

class ViewController: UIViewController, MFMailComposeViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func composeEmail(_ sender: UIBarButtonItem) {
        print("Compose email")
        sendEmail()
    }
    
    // MARK: - Email
    
    func createDataDumpOfMatchReports() -> Data {
        let mailString = NSMutableString()
        mailString.append("Tournament,Match Number,Team Number,Auto Crossed Line,Auto Fuel High,Auto Fuel Low,Auto Score,Auto Scores Gear,Comments,DefenseFaced,Fuel From Feeder,Fuel From Floor,Fuel From Hopper,Fuel High,Fuel Low,Gear Cycle,Gears,Gears From Feeder,Gears From Floor,Hang,Hang Speed,Match Result,Penalty,Rotors Started,Shots Location,Tele Score\n")
        CoreDataStack.defaultStack.syncWithCompletion(nil)
        let fetchRequest = NSFetchRequest<MatchReport>(entityName: "MatchReport")
        let tournamentSort = NSSortDescriptor(key: "tournament", ascending: true)
        let teamSort = NSSortDescriptor(key: "teamNumber", ascending:true)
        var sortsArray: [NSSortDescriptor] = []
        let matchSort = NSSortDescriptor(key: "matchNumber", ascending:true)
        sortsArray.append(tournamentSort)
        sortsArray.append(matchSort)
        sortsArray.append(teamSort)
        fetchRequest.sortDescriptors = sortsArray
        var matches: [MatchReport] = []
        do {
            matches = try CoreDataStack.defaultStack.managedObjectContext.fetch(fetchRequest)
            print("Retrieved \(matches.count) matches")
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        for match in matches {
            mailString.append("\(match.tournament),\(match.matchNumber!),\(match.teamNumber!),\(match.autoCrossedLine),\(match.autoFuelHigh),\(match.autoFuelLow),\(match.autoScore),\(match.autoScoresGear),\(match.comments!),\(match.defenseFaced),\(match.fuelFromFeeder),\(match.fuelFromFloor),\(match.fuelFromHopper),\(match.fuelHigh),\(match.fuelLow),\(match.gearCycle),\(match.gears),\(match.gearsFromFeeder),\(match.gearsFromFloor),\(match.hang),\(match.hangSpeed),\(match.matchResult),\(match.penalty),\(match.rotorsStarted),\(match.shotsLocation),\(match.teleScore)\n")
        }
        let data = mailString.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)
        return data!
    }
    
    func createDataDumpOfPitReports() -> Data {
        let mailString = NSMutableString()
        mailString.append("Team Number,Auto Cross,Auto Fuel High,Auto Fuel Low,Auto Scores Gear,Comment Proud,Comments Other,Contact Name,Drive Coach,Drive Train Motor Num,Drive Train Motor Type,Drive Train Type,Estimated Storage,Estimated Hang Time,Final Score,Fuel Pickup Speed,Fuel Pickup  Feeder,Fuel Pickup Floor,Fuel Pickup Hopper,Gears Feeder Pickup Speed,Gears Floor Pickup Speed,Gears Pickup Feeder,Gears Pickup Floor,Practice Amount,Preferred Start Location,Rating,Robot Weight,Rotors Started,Shot Accurate,Shot Location\n")
        CoreDataStack.defaultStack.syncWithCompletion(nil)
        let fetchRequest = NSFetchRequest<PitReport>(entityName: "PitReport")
        let teamSort = NSSortDescriptor(key: "teamNumber", ascending:true)
        var sortsArray: [NSSortDescriptor] = []
        sortsArray.append(teamSort)
        fetchRequest.sortDescriptors = sortsArray
        var reports: [PitReport] = []
        do {
            reports = try CoreDataStack.defaultStack.managedObjectContext.fetch(fetchRequest)
            print("Retrieved \(reports.count) pit reports")
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        for pit in reports {
            mailString.append("\(pit.teamNumber!),\(pit.autoCross),\(pit.autoFuelHigh),\(pit.autoFuelLow),\(pit.autoScoresGear),\(pit.commentsProud!),\(pit.commentsStillWorkingOn!),\(pit.contactName!),\(pit.driveCoach!),\(pit.driveTrainMotorNum),\(pit.driveTrainMotorType),\(pit.driveTrainType),\(pit.estimatedStorageVolumne),\(pit.estimatedTimeToHang),\(pit.finalScore),\(pit.fuelFloorPickupSpeed),\(pit.fuelPickupFromFeeder),\(pit.fuelPickupFromFloor),\(pit.fuelPickupFromHopper),\(pit.gearsFeederPickupSpeed),\(pit.gearsFloorPickupSpeed),\(pit.gearsPickupFromFeeder),\(pit.gearsPickupFromFloor),\(pit.practiceAmount),\(pit.preferredStartLocation),\(pit.rating),\(pit.robotWeight),\(pit.rotorsStarted),\(pit.shotIsAccurate),\(pit.shotLocation)\n")
        }

        let data = mailString.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)
        return data!
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            let now = Date()
            let nowString = DateFormatter.localizedString(
                from: now,
                dateStyle: .short,
                timeStyle: .short)
            mail.setSubject("FRCScout2017 Data Dump as of \(nowString)")
            let matchData = createDataDumpOfMatchReports()
            mail.setMessageBody("", isHTML: false)
            mail.addAttachmentData(matchData, mimeType: "text/csv", fileName: "FRCScout2017_Match_Data.csv")
            let pitData = createDataDumpOfPitReports()
            mail.setMessageBody("", isHTML: false)
            mail.addAttachmentData(pitData, mimeType: "text/csv", fileName: "FRCScout2017_Pit_Data.csv")
            present(mail, animated: true, completion: nil)
        } else {
            displayErrorAlertWithOk("This device is not configured for email")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func displayErrorAlertWithOk(_ msg: String) {
        let refreshAlert = UIAlertController(title: "Error", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            print("Notify user of error")
            return
        }))
        
        DispatchQueue.main.async(execute: {
            self.present(refreshAlert, animated: true, completion: nil)
        })
    }


}


//
//  AddMatchViewController.swift
//  FRCScout2017
//
//  Created by Sharon Kass on 2/5/17.
//  Copyright © 2017 RoboTigers. All rights reserved.
//

import UIKit
import Ensembles

class AddMatchViewController: UIViewController {
    
    // MARK: - Data passed in from segue
    
    var selectedTournament : Int16 = 0
    
    // MARK: - Outlets and Actions for components of add-match scene
    
    @IBOutlet weak var match: UITextField!
    @IBOutlet weak var team: UITextField!
    @IBOutlet weak var autoCrosses: UISwitch!
    @IBOutlet weak var autoScoresGear: UISwitch!
    @IBOutlet weak var autoFuelHighLabel: UILabel!
    @IBOutlet weak var gearCycle: UISegmentedControl!
    @IBOutlet weak var teleFuelHighLabel: UILabel!
    @IBOutlet weak var teleFuelLowLabel: UILabel!
    @IBOutlet weak var shotsLocation: UISegmentedControl!
    @IBOutlet weak var fuelFromFloor: UISwitch!
    @IBOutlet weak var fuelFromFeeder: UISwitch!
    @IBOutlet weak var fuelFromHopper: UISwitch!
    @IBOutlet weak var hangSpeed: UISegmentedControl!
    @IBOutlet weak var penalty: UISwitch!
    @IBOutlet weak var hang: UISwitch!
    @IBOutlet weak var defenseFaced: UISegmentedControl!
    @IBOutlet weak var gearsPickedFromFloor: UISwitch!
    @IBOutlet weak var gearsPickedFromFeeder: UISwitch!
    @IBOutlet weak var autoFuelLowLabel: UILabel!
    @IBOutlet weak var comments: UITextView!
    @IBOutlet weak var gearsLabel: UILabel!
    @IBOutlet weak var rotorsStarted: UITextField!
    @IBOutlet weak var autoScore: UITextField!
    @IBOutlet weak var teleScore: UITextField!
    

    
    @IBAction func autoHighFuelStepper(_ sender: UIStepper) {
        autoFuelHighLabel.text = String((Int(sender.value).description))
    }
    
    @IBAction func autoFuelLowStepper(_ sender: UIStepper) {
        autoFuelLowLabel.text = String((Int(sender.value).description))
    }
    @IBAction func teleFuelHighStepper(_ sender: UIStepper) {
        teleFuelHighLabel.text = String((Int(sender.value).description))
    }
    @IBAction func teleFuelLowStepper(_ sender: UIStepper) {
        teleFuelLowLabel.text = String((Int(sender.value).description))
    }

    @IBAction func gearStepper(_ sender: UIStepper) {
        gearsLabel.text = String((Int(sender.value).description))
    }
    
    
    // MARK: - View functions
    
    override func viewDidLoad() {
        print("in viewDidLoad")
        super.viewDidLoad()
        print("AddMatchViewController - view loaded with selectedTourname = \(selectedTournament)")
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
    
    
    // MARK: - Cancel action
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let refreshAlert = UIAlertController(title: "Are you sure?", message: "Data on this screen will be lost if you do not save first.", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            print("Cancel from add-match scene")
            self.dismiss(animated: true, completion: nil)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Cancel the cancel, stay on the screen")
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    
    // MARK: - Save/Update action
    
    /*
     * Save/Update the entered data into the data store. First check for required fields.
     *
     * The unique key for a match report record is:
     *    Tournament_Match_Team
     */
    @IBAction func save(_ sender: UIBarButtonItem) {
        print("Save match record to data store")
        if ((match.text)!.isEmpty || (team.text)!.isEmpty) {
            displayErrorAlertWithOk("Match and Team Number is required!")
        } else {
            // save the report to the data store
//            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//                return
//            }
//            let context = appDelegate.persistentContainer.viewContext
//            let matchReport = MatchReport(context: context)
            
            // Set matchReport variable to either a new match report or an existing match report
            CoreDataStack.defaultStack.syncWithCompletion(nil)
            let fetchRequest = NSFetchRequest<MatchReport>(entityName: "MatchReport")
            //fetchRequest.predicate = NSPredicate(format: "uniqueIdentifier == \(uniqueIdentifier)")
            fetchRequest.predicate = NSPredicate(format: "tournament == \(selectedTournament) AND matchNumber == \(match.text!) AND teamNumber == \(team.text!)")
            var dupMatches: [MatchReport] = []
            do {
                dupMatches = try CoreDataStack.defaultStack.managedObjectContext.fetch(fetchRequest)
                print("Retrieved \(dupMatches.count) duplicate matches")
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            var existingMatchReport : MatchReport?
            if (dupMatches.count > 0) {
                existingMatchReport = dupMatches[0]
            }
            var matchReport : MatchReport? = nil
            if (existingMatchReport != nil) {
                matchReport = existingMatchReport
            } else {
                matchReport = NSEntityDescription.insertNewObject(forEntityName: "MatchReport", into: CoreDataStack.defaultStack.managedObjectContext) as? MatchReport
            }
            
            // Add or update match report
            //let matchReport : MatchReport = NSEntityDescription.insertNewObject(forEntityName: "MatchReport", into: CoreDataStack.defaultStack.managedObjectContext) as! MatchReport
            let uniqueIdentifier = "\(selectedTournament)_\(match.text!)_\(team.text!)"
            matchReport?.tournament = selectedTournament
            matchReport?.matchNumber = match.text!
            matchReport?.teamNumber = team.text!
            matchReport?.uniqueIdentifier = uniqueIdentifier
            matchReport?.autoCrossedLine = autoCrosses.isOn
            matchReport?.autoScoresGear = autoScoresGear.isOn
            matchReport?.autoFuelHigh = (Int16(autoFuelHighLabel.text!))!
            matchReport?.autoFuelLow = (Int16(autoFuelLowLabel.text!))!
            matchReport?.gears = (Int16(gearsLabel.text!))!
            matchReport?.gearCycle = Int16(gearCycle.selectedSegmentIndex)
            matchReport?.fuelHigh = (Int16(teleFuelHighLabel.text!))!
            matchReport?.fuelLow = (Int16(teleFuelLowLabel.text!))!
            matchReport?.gearsFromFloor = gearsPickedFromFloor.isOn
            matchReport?.gearsFromFeeder = gearsPickedFromFeeder.isOn
            matchReport?.shotsLocation = Int16(shotsLocation.selectedSegmentIndex)
            matchReport?.fuelFromFloor = fuelFromFloor.isOn
            matchReport?.fuelFromFeeder = fuelFromFeeder.isOn
            matchReport?.fuelFromHopper = fuelFromHopper.isOn
            matchReport?.hangSpeed = Int16(hangSpeed.selectedSegmentIndex)
            matchReport?.hang = hang.isOn
            matchReport?.penalty = penalty.isOn
            matchReport?.defenseFaced = Int16(defenseFaced.selectedSegmentIndex)
            matchReport?.comments = comments.text!
            matchReport?.rotorsStarted = (Int16(rotorsStarted.text!))!
            matchReport?.autoScore = (Int16(autoScore.text!))!
            matchReport?.teleScore = (Int16(teleScore.text!))!
//            
//            do {
                print("Save match record: \(matchReport)")
                //try context.save()
                CoreDataStack.defaultStack.saveContext()
                CoreDataStack.defaultStack.syncWithCompletion(nil)
//            } catch let error as NSError {
//                print("Could not save the match report. \(error), \(error.userInfo)")
//            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
}

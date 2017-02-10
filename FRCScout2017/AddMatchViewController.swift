//
//  AddMatchViewController.swift
//  FRCScout2017
//
//  Created by Sharon Kass on 2/5/17.
//  Copyright © 2017 RoboTigers. All rights reserved.
//

import UIKit

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
    @IBOutlet weak var autoFuelLowLabel: UILabel!
    @IBOutlet weak var teleFuelHighLabel: UILabel!
    @IBOutlet weak var teleFuelLowLabel: UILabel!
    @IBOutlet weak var shotsLocation: UISegmentedControl!
    @IBOutlet weak var fuelFromFloor: UISwitch!
    @IBOutlet weak var fuelFromFeeder: UISwitch!
    @IBOutlet weak var fuelFromHopper: UISwitch!
    @IBOutlet weak var hangSpeed: UISegmentedControl!
    
    // SABRINA: Plesae continue here wiring up all the outlets
    
    // SABRINA: Please continue here wiring up all the actions
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
    
    
    // MARK: - View functions
    
    override func viewDidLoad() {
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
    
    
    // MARK: - Save action
    
    /*
     * Save the entered data into the data store. First check for required fields.
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
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let context = appDelegate.persistentContainer.viewContext
            let matchReport = MatchReport(context: context)
            let uniqueIdentifier = "\(selectedTournament)_\(match.text!)_\(team.text!)"
            matchReport.tournament = selectedTournament
            matchReport.matchNumber = match.text!
            matchReport.teamNumber = team.text!
            matchReport.uniqueIdentifier = uniqueIdentifier
            matchReport.autoCrossedLine = autoCrosses.isOn
            matchReport.autoFuelHigh = (Int16(autoFuelHighLabel.text!))!
            matchReport.gearCycle = Int16(gearCycle.selectedSegmentIndex)
            matchReport.autoFuelLow = (Int16(autoFuelLowLabel.text!))!
            matchReport.fuelHigh = (Int16(teleFuelHighLabel.text!))!
            matchReport.fuelLow = (Int16(teleFuelLowLabel.text!))!
            matchReport.shotsLocation = Int16(shotsLocation.selectedSegmentIndex)
            matchReport.fuelFromFloor = fuelFromFloor.isOn
            matchReport.fuelFromFeeder = fuelFromFeeder.isOn
            matchReport.fuelFromHopper = fuelFromHopper.isOn
            matchReport.hangSpeed = Int16(hangSpeed.selectedSegmentIndex)
            
            // SABRINA: Keep going from here please add the entity attributes to matchReport so it can be stored to data store
            do {
                print("Save match record: \(matchReport)")
                try context.save()
            } catch let error as NSError {
                print("Could not save the match report. \(error), \(error.userInfo)")
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
}

//
//  AddMatchViewController.swift
//  FRCScout2017
//
//  Created by Sharon Kass on 2/5/17.
//  Copyright © 2017 RoboTigers. All rights reserved.
//

import UIKit
import Ensembles

// This scene allows the user to view existing match reports and update them or add a new match report.

class AddMatchViewController: UIViewController, UITextViewDelegate {
    
    // MARK: - Variables to manage the keyboard so that the comments textView is not obstructed
    
    var moveValue: CGFloat!
    var moved: Bool = false
    var lowerFieldBeingEdited: Bool = false
    
    // MARK: - Data passed in from segue
    
    var selectedTournament : Int16 = -1
    var selectedMatchNumber = ""
    var selectedTeamNumber = ""
    
    // If existingMatchReport is not nil then that means we were able to retrieve an existing 
    // match report from the data store so this is a view/update situation
    var existingMatchReport : MatchReport?
    
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
    @IBOutlet weak var matchResult: UISegmentedControl!
    @IBOutlet weak var defensePlayed: UISegmentedControl!
    @IBOutlet weak var defensePlayedLevel: UISegmentedControl!
    

    
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
        
        // Set up a keyboard observer so we can shift the screen up when comments are being entered
        // and thus avoid having that comments textView obstructed by the keyboard
        self.comments.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: .UIKeyboardDidShow, object: nil)

        
        // Fill outlets with any existing report data
        print("AddMatchViewController - view loaded with selectedTournament = \(selectedTournament), selectedMatchNumber = \(selectedMatchNumber), selectedTeamNumber = \(selectedTeamNumber)")
        CoreDataStack.defaultStack.syncWithCompletion(nil)
        let fetchRequest = NSFetchRequest<MatchReport>(entityName: "MatchReport")
        if selectedTournament != -1 && selectedMatchNumber != "" && selectedTeamNumber != "" {
            fetchRequest.predicate = NSPredicate(format: "tournament == \(selectedTournament) AND matchNumber == \(selectedMatchNumber) AND teamNumber == \(selectedTeamNumber)")
            var existingMatches: [MatchReport] = []
            do {
                existingMatches = try CoreDataStack.defaultStack.managedObjectContext.fetch(fetchRequest)
                print("Retrieved \(existingMatches.count) existing matches")
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            if (existingMatches.count > 0) {
                existingMatchReport = existingMatches[0]
                // load outlets with values from existing match report
                match.text = existingMatchReport?.matchNumber
                team.text = existingMatchReport?.teamNumber
                autoCrosses.isOn = (existingMatchReport?.autoCrossedLine)!
                autoScoresGear.isOn = (existingMatchReport?.autoScoresGear)!
                autoFuelHighLabel.text = NSNumber(value: (existingMatchReport?.autoFuelHigh)!).stringValue
                autoFuelLowLabel.text = NSNumber(value: (existingMatchReport?.autoFuelLow)!).stringValue
                gearCycle.selectedSegmentIndex = Int((existingMatchReport?.gearCycle)!)
                teleFuelHighLabel.text = NSNumber(value: (existingMatchReport?.fuelHigh)!).stringValue
                teleFuelLowLabel.text = NSNumber(value: (existingMatchReport?.fuelLow)!).stringValue
                gearsLabel.text = NSNumber(value: (existingMatchReport?.gears)!).stringValue
                gearsPickedFromFloor.isOn = (existingMatchReport?.gearsFromFloor)!
                gearsPickedFromFeeder.isOn = (existingMatchReport?.gearsFromFeeder)!
                defenseFaced.selectedSegmentIndex = Int((existingMatchReport?.defenseFaced)!)
                shotsLocation.selectedSegmentIndex = Int((existingMatchReport?.shotsLocation)!)
                fuelFromFloor.isOn = (existingMatchReport?.fuelFromFloor)!
                fuelFromFeeder.isOn = (existingMatchReport?.fuelFromFeeder)!
                fuelFromHopper.isOn = (existingMatchReport?.fuelFromHopper)!
                hangSpeed.selectedSegmentIndex = Int((existingMatchReport?.hangSpeed)!)
                rotorsStarted.text = NSNumber(value: (existingMatchReport?.rotorsStarted)!).stringValue
                hang.isOn = (existingMatchReport?.hang)!
                penalty.isOn = (existingMatchReport?.penalty)!
                comments.text = existingMatchReport?.comments
                matchResult.selectedSegmentIndex = Int((existingMatchReport?.matchResult)!)
                defensePlayed.selectedSegmentIndex = Int((existingMatchReport?.defensePlayed)!)
                defensePlayedLevel.selectedSegmentIndex = Int((existingMatchReport?.defensePlayedLevel)!)
            }
        }

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
            var matchReport : MatchReport? = nil
            if (existingMatchReport != nil) {
                matchReport = existingMatchReport
            } else {
                matchReport = NSEntityDescription.insertNewObject(forEntityName: "MatchReport", into: CoreDataStack.defaultStack.managedObjectContext) as? MatchReport
            }
            
            // Add or update match report
            //let matchReport : MatchReport = NSEntityDescription.insertNewObject(forEntityName: "MatchReport", into: CoreDataStack.defaultStack.managedObjectContext) as! MatchReport
            if selectedTournament == -1 {
                print("Somehow selectedTournament is not set, this should never happen. We will use 0 as default value")
                selectedTournament = 0
            }
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
            matchReport?.matchResult = Int16(matchResult.selectedSegmentIndex)
            matchReport?.defensePlayed = Int16(defensePlayed.selectedSegmentIndex)
            matchReport?.defensePlayedLevel = Int16(defensePlayedLevel.selectedSegmentIndex)
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
    
    // MARK: - Keyboard Management
    
    // These functions manage the keyboard so that the comments textView is not obstructed
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        print("animateViewMoving")
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }

    func keyboardDidShow(notification: Notification) {
        print("keyboardDidShow")
        if (lowerFieldBeingEdited) {
            print("Lower field being edited so shift view up to avoid keyboard obstruction")
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                let keyboardHeight = keyboardSize.height
                if (view.frame.size.height-self.comments.frame.origin.y) - self.comments.frame.size.height < keyboardHeight{
                    moveValue = keyboardHeight - ((view.frame.size.height-self.comments.frame.origin.y) - self.comments.frame.size.height)
                    self.animateViewMoving(up: true, moveValue: moveValue )
                    moved = true
                }
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("textViewDidBeginEditing")
        if textView == comments {
            print("beginning lower field editing")
            lowerFieldBeingEdited = true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("textViewDidEndEditing")
        if textView == comments {
            print("ending lower field editing")
            lowerFieldBeingEdited = false
        }
        if moved == true {
            self.animateViewMoving(up: false, moveValue: moveValue )
            moved = false
        }
    }
    
    
    
}

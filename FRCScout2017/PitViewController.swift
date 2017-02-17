//
//  PitViewController.swift
//  FRCScout2017
//
//  Created by Sharon Kass on 2/10/17.
//  Copyright © 2017 RoboTigers. All rights reserved.
//

import UIKit
import CoreData

class PitViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // SHARON TEST 
    let sharon = 1
    var selectedTeamNumber = ""
    var selectedDriveTrainType = ""
    var existingPitReport : PitReport?
    
    let driveTrainTypes = ["Tank", "H Drive", "Omni", "Halo", "Arcade"]

    // MARK: - Outlets and Actions for screen widgets
    
    @IBOutlet weak var contactName: UITextField!
    @IBOutlet weak var driveTrainTypePicker: UIPickerView!
    @IBOutlet weak var driveTrainMotorType: UISegmentedControl!
    @IBOutlet weak var driveTrainMotorNum: UITextField!
    @IBOutlet weak var crossesLineSwitch: UISwitch!
    @IBOutlet weak var fuelPickupFromFloor: UISwitch!
    @IBOutlet weak var fuelPickupFromFeeder: UISwitch!
    @IBOutlet weak var fuelFloorPickupSpeed: UISegmentedControl!
    @IBOutlet weak var fuelPickupFromHopper: UISwitch!
    @IBOutlet weak var estimatedStorageVolumne: UITextField!
    @IBOutlet weak var shotIsAccurate: UISwitch!
    @IBOutlet weak var estimatedTimeToHang: UISegmentedControl!
    @IBOutlet weak var commentsProud: UITextField!
    @IBOutlet weak var commentsStillWorkingOn: UITextField!
    @IBOutlet weak var finalScore: UITextField!
    @IBOutlet weak var gearsPickupFromFloor: UISwitch!
    @IBOutlet weak var gearsPickupFromFeeder: UISwitch!
    @IBOutlet weak var shotLocation: UISegmentedControl!
    @IBOutlet weak var gearsFeederPickupSpeed: UISegmentedControl!
    @IBOutlet weak var gearsFloorPickupSpeed: UISegmentedControl!
    @IBOutlet weak var autoFuelLow: UITextField!
    @IBOutlet weak var autoFuelHigh: UITextField!
    @IBOutlet weak var preferedStarLocation: UISegmentedControl!
    @IBOutlet weak var autoScoresGear: UISwitch!
    @IBOutlet weak var rotorsStarted: UITextField!
    @IBOutlet weak var rating: UISlider!

    
    @IBOutlet weak var preferedStartLocation: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        driveTrainTypePicker.dataSource = self
        driveTrainTypePicker.delegate = self
        
        // Set title to indicate the selected team entered via the segue
        title = "Team \(selectedTeamNumber) Pit Report"
        
        if (selectedTeamNumber == "") {
            displayErrorAlertWithOk("Please pick a team first")
            self.dismiss(animated: true, completion: nil)
        } else {
            // Get pit report for the selected team, if a report exists in the data store
            // There should only be one pit report but use an array here to be safe
            var pitReports: [PitReport] = []
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<PitReport>(entityName: "PitReport")
            fetchRequest.predicate = NSPredicate(format: "teamNumber == \(selectedTeamNumber)")
            do {
                pitReports = try context.fetch(fetchRequest)
                if pitReports.count > 0 {
                    // There should only be one pit report for a team but if more are found
                    // then just ignore them - we take the first (0th position) array element
                    existingPitReport = pitReports[0]
                    contactName.text = existingPitReport?.contactName
                    driveTrainTypePicker.reloadAllComponents()
                    var typeRow = 0
                    for (typeIndex, typeString) in driveTrainTypes.enumerated() {
                        if typeString == existingPitReport?.driveTrainType {
                            typeRow = typeIndex
                            break
                        }
                    }
                    driveTrainTypePicker.selectRow(typeRow, inComponent: 0, animated: false)
                    driveTrainMotorType.selectedSegmentIndex = Int((existingPitReport?.driveTrainMotorType)!)
                    driveTrainMotorNum.text = NSNumber(value: (existingPitReport?.driveTrainMotorNum)!).stringValue
                    crossesLineSwitch.isOn = (existingPitReport?.autoCross)!
                    autoScoresGear.isOn = (existingPitReport?.autoScoresGear)!
                    gearsPickupFromFloor.isOn = (existingPitReport?.gearsPickupFromFloor)!
                    
                    gearsPickupFromFeeder.isOn = (existingPitReport?.gearsPickupFromFeeder)!
                    fuelPickupFromFloor.isOn = (existingPitReport?.fuelPickupFromFloor)!
                    fuelPickupFromFeeder.isOn = (existingPitReport?.fuelPickupFromFeeder)!
                    fuelPickupFromHopper.isOn = (existingPitReport?.fuelPickupFromHopper)!
                    shotIsAccurate.isOn = (existingPitReport?.shotIsAccurate)!
                    gearsFloorPickupSpeed.selectedSegmentIndex = Int((existingPitReport?.gearsFloorPickupSpeed)!)
                    gearsFeederPickupSpeed.selectedSegmentIndex = Int((existingPitReport?.gearsFeederPickupSpeed)!)
                    
                    
                
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    //SABRINA: STEP 2: Pre=populate each screen widget with the value
                    // from the existing data record in the store
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
        
        
    }
    
    @IBAction func rating(_ sender: UISlider) {
     //   rating.text = String(Int(sender.value))
    }
    @IBAction func save(_ sender: UIBarButtonItem) {
        // save the report to the data store either using a new object to updating an existing object
        var pitRecord : PitReport? = nil
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        if (existingPitReport != nil) {
            pitRecord = existingPitReport
        } else {
            pitRecord = PitReport(context: context)
        }
        pitRecord?.teamNumber = selectedTeamNumber
        pitRecord?.contactName = contactName.text!
        pitRecord?.driveTrainType = selectedDriveTrainType
        pitRecord?.driveTrainMotorType = Int16(driveTrainMotorType.selectedSegmentIndex)
        pitRecord?.driveTrainMotorNum = Int16(driveTrainMotorNum.text!)!
        pitRecord?.autoCross = crossesLineSwitch.isOn
        pitRecord?.fuelPickupFromFloor = fuelPickupFromFloor.isOn
        pitRecord?.fuelPickupFromFeeder = fuelPickupFromFeeder.isOn
        pitRecord?.fuelFloorPickupSpeed = Int16(fuelFloorPickupSpeed.selectedSegmentIndex)
        pitRecord?.fuelPickupFromHopper = fuelPickupFromHopper.isOn
        pitRecord?.shotIsAccurate = shotIsAccurate.isOn
        pitRecord?.estimatedTimeToHang = Int16(estimatedTimeToHang.selectedSegmentIndex)
        pitRecord?.commentsProud = commentsProud.text!
        pitRecord?.commentsStillWorkingOn = commentsStillWorkingOn.text!
        pitRecord?.autoFuelLow = Int16(autoFuelLow.text!)!
        pitRecord?.estimatedStorageVolumne = Int16(estimatedStorageVolumne.text!)!
        print("NOW SAVE autoFuelHigh text value which is \(autoFuelHigh.text)")
        pitRecord?.autoFuelHigh = Int16(autoFuelHigh.text!)!
        pitRecord?.autoScoresGear = autoScoresGear.isOn
        pitRecord?.gearsFeederPickupSpeed = Int16(gearsFeederPickupSpeed.selectedSegmentIndex)
        pitRecord?.gearsPickupFromFloor = gearsPickupFromFloor.isOn
        pitRecord?.gearsPickupFromFeeder = gearsPickupFromFeeder.isOn
        pitRecord?.gearsFloorPickupSpeed = Int16(gearsFloorPickupSpeed.selectedSegmentIndex)
        pitRecord?.preferredStartLocation = Int16(preferedStarLocation.selectedSegmentIndex)
        pitRecord?.shotLocation = Int16(shotLocation.selectedSegmentIndex)
        pitRecord?.shotIsAccurate = shotIsAccurate.isOn

        
        
        
        
        
        //SABRINA: STEP 3: Save the value of each widget you wire
        print("Pit Record is: \(pitRecord)")
        do {
            print("Save pit record: \(pitRecord))")
            try context.save()
        } catch let error as NSError {
            print("Could not save the pit report. \(error), \(error.userInfo)")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let refreshAlert = UIAlertController(title: "Are you sure?", message: "Any changes you made on this screen will be lost if you do not save first.", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            print("Cancel from add-pit scene")
            self.dismiss(animated: true, completion: nil)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Cancel the cancel, stay on the screen")
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    
    // MARK: - Picker
    
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

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Utilities
    
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

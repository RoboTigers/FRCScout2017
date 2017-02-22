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
    @IBOutlet weak var driveTrainsTypePicker: UIPickerView!
    @IBOutlet weak var motorType: UISegmentedControl!
    @IBOutlet weak var overallSpeed: UILabel!
    @IBOutlet weak var robotWeightt: UILabel!
    @IBOutlet weak var cheesecake: UILabel!
    @IBOutlet weak var storageVolume: UILabel!
    

    
    
    override func viewDidLoad() {
        print("In viewDidLoad of summary scene")
        print("selected team is \(selectedTeamNumber)")
        super.viewDidLoad()
       // driveTrainsTypePicker.dataSource = self
        //driveTrainsTypePicker.delegate = self
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
                driveTrainsTypePicker.reloadAllComponents()
                var typeRow = 0
                for (typeIndex, typeString) in driveTrainTypes.enumerated() {
                    if typeString == existingPitReport.driveTrainType {
                        typeRow = typeIndex
                        break
                    }
                }
                driveTrainsTypePicker.selectRow(typeRow, inComponent: 0, animated: false)
                motorType.selectedSegmentIndex = Int(Int16(existingPitReport.driveTrainMotorType))
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

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

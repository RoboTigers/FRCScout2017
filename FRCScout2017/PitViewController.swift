//
//  PitViewController.swift
//  FRCScout2017
//
//  Created by Sharon Kass on 2/10/17.
//  Copyright © 2017 RoboTigers. All rights reserved.
//

import UIKit

class PitViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var selectedTeam = ""
    var selectedDriveTrainType = "Type 1"
    
    let driveTrainTypes = ["Type 1", "Type 2", "Type 3", "Type 4", "Type 5"]

    // MARK: - Outlets and Actions for screen widgets
    
    @IBOutlet weak var contactName: UITextField!
    @IBOutlet weak var driveTrainTypePicker: UIPickerView!
    @IBOutlet weak var driveTrainMotorType: UISegmentedControl!
    @IBOutlet weak var driveTrainMotorNum: UITextField!
    @IBOutlet weak var crossesLineSwitch: UISwitch!
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        print("Save pit record to data store")
        // save the report to the data store
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        let pitRecord = PitReport(context: context)
        pitRecord.teamNumber = selectedTeam
        pitRecord.contactName = contactName.text!
        pitRecord.driveTrainType = selectedDriveTrainType
        pitRecord.driveTrainMotorType = Int16(driveTrainMotorType.selectedSegmentIndex)
        pitRecord.autoCross = crossesLineSwitch.isOn
        print("Pit Record is: \(pitRecord)")
        
            do {
                print("Save pit record: \(pitRecord))")
                try context.save()
            } catch let error as NSError {
                print("Could not save the pit report. \(error), \(error.userInfo)")
            }
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Team \(selectedTeam) Pit Report"
        driveTrainTypePicker.dataSource = self
        driveTrainTypePicker.delegate = self
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

}

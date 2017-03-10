//
//  PitViewController.swift
//  FRCScout2017
//
//  Created by Sharon Kass on 2/10/17.
//  Copyright © 2017 RoboTigers. All rights reserved.
//

import UIKit
import CoreData

class PitViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Variables to manage the keyboard so that the comments textView is not obstructed
    
    var moveValue: CGFloat!
    var moved: Bool = false
    var lowerTextFieldBeingEdited: Bool = false
    
    // MARK: - Data model
    
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
    @IBOutlet weak var preferredStartLocation: UISegmentedControl!
    @IBOutlet weak var autoScoresGear: UISwitch!
    @IBOutlet weak var rotorsStarted: UITextField!
    @IBOutlet weak var rating: UISlider!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var driveCoach: UITextField!
    @IBOutlet weak var robotWeight: UITextField!
    @IBOutlet weak var practiceSegControl: UISegmentedControl!
    let picker = UIImagePickerController()
    @IBOutlet weak var myImageView: UIImageView!
        @IBAction func shootPhoto(_ sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.cameraCaptureMode = .photo
            picker.modalPresentationStyle = .fullScreen
            present(picker,animated: true,completion: nil)
        } else {
            noCamera()
        }
    }
    func noCamera(){
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(
            alertVC,
            animated: true,
            completion: nil)
    }
    
    
    override func viewDidLoad() {
        picker.delegate = self
        super.viewDidLoad()
        
        // Set up a keyboard observer so we can shift the screen up when comments are being entered
        // and thus avoid having that comments textView obstructed by the keyboard
        self.estimatedStorageVolumne.delegate = self
        self.robotWeight.delegate = self
        self.commentsProud.delegate = self
        self.commentsStillWorkingOn.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: .UIKeyboardDidShow, object: nil)
        
        // Set up an observer so we know when the drive motor num value changes. We need to check it is <= 6
        driveTrainMotorNum.delegate = self
        driveTrainMotorNum.addTarget(self, action: #selector(driveMotorNumDidChange(_:)), for: .editingChanged)

        
        // Fill outlets iwth any existing report data
        driveTrainTypePicker.dataSource = self
        driveTrainTypePicker.delegate = self
        
        if (selectedTeamNumber == "") {
            displayErrorAlertWithOk("Please pick a team first")
            self.dismiss(animated: true, completion: nil)
        } else {
            // Get pit report for the selected team, if a report exists in the data store
            // There should only be one pit report but use an array here to be safe
            var pitReports: [PitReport] = []
//            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//                return
//            }
//            let context = appDelegate.persistentContainer.viewContext
            CoreDataStack.defaultStack.syncWithCompletion(nil)
            let fetchRequest = NSFetchRequest<PitReport>(entityName: "PitReport")
            fetchRequest.predicate = NSPredicate(format: "teamNumber == \(selectedTeamNumber)")
            do {
                pitReports = try CoreDataStack.defaultStack.managedObjectContext.fetch(fetchRequest)
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
                    rating.setValue((existingPitReport?.rating)!, animated: true)
                    ratingLabel.text = NSNumber(value: (existingPitReport?.rating)!).stringValue
                    preferredStartLocation.selectedSegmentIndex = Int((existingPitReport?.preferredStartLocation)!)
                    shotLocation.selectedSegmentIndex = Int((existingPitReport?.shotLocation)!)
                    robotWeight.text = NSNumber(value: (existingPitReport?.robotWeight)!).stringValue
                    if existingPitReport?.robotImage != nil {
                        let existingImage = UIImage(data: (existingPitReport?.robotImage)! as Data)
                        myImageView.image = existingImage
                        myImageView.contentMode = .scaleAspectFit
                    }
                    driveCoach.text = existingPitReport?.driveCoach
                    estimatedStorageVolumne.text = NSNumber(value: (existingPitReport?.estimatedStorageVolumne)!).stringValue
                    commentsProud.text = existingPitReport?.commentsProud
                    commentsStillWorkingOn.text = existingPitReport?.commentsStillWorkingOn
                    autoFuelLow.text = NSNumber(value: (existingPitReport?.autoFuelLow)!).stringValue
                    autoFuelHigh.text = NSNumber(value: (existingPitReport?.autoFuelHigh)!).stringValue
                    practiceSegControl.selectedSegmentIndex = (Int((existingPitReport?.practiceAmount)!))
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Set title to indicate the selected team entered via the segue
        title = "Team \(selectedTeamNumber) Pit Report"
    }
    
    @IBAction func rating(_ sender: UISlider) {
        ratingLabel.text = NSString(format: "%1.1f", sender.value) as String
    }
    
    func driveMotorNumDidChange(_ textField: UITextField) {
        let driveTrainMotorNumToBeSaved = Int16(driveTrainMotorNum.text!)!
        let driveTrainMotorTypeToBeSaved = driveTrainMotorType.selectedSegmentIndex
        if (driveTrainMotorTypeToBeSaved == 0 && driveTrainMotorNumToBeSaved > 6) {
            displayErrorAlertWithOk("Numer of drive train motors must not exceed 6")
        }
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        // save the report to the data store either using a new object to updating an existing object
        var pitRecord : PitReport? = nil
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            return
//        }
//        let context = appDelegate.persistentContainer.viewContext
        CoreDataStack.defaultStack.syncWithCompletion(nil)
        if (existingPitReport != nil) {
            pitRecord = existingPitReport
        } else {
            //pitRecord = PitReport(context: context)
            pitRecord = NSEntityDescription.insertNewObject(forEntityName: "PitReport", into: CoreDataStack.defaultStack.managedObjectContext) as? PitReport
        }
        pitRecord?.teamNumber = selectedTeamNumber
        pitRecord?.uniqueIdentifier = selectedTeamNumber
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
        pitRecord?.autoFuelHigh = Int16(autoFuelHigh.text!)!
        pitRecord?.autoScoresGear = autoScoresGear.isOn
        pitRecord?.gearsFeederPickupSpeed = Int16(gearsFeederPickupSpeed.selectedSegmentIndex)
        pitRecord?.gearsPickupFromFloor = gearsPickupFromFloor.isOn
        pitRecord?.gearsPickupFromFeeder = gearsPickupFromFeeder.isOn
        pitRecord?.gearsFloorPickupSpeed = Int16(gearsFloorPickupSpeed.selectedSegmentIndex)
        pitRecord?.preferredStartLocation = Int16(preferredStartLocation.selectedSegmentIndex)
        pitRecord?.shotLocation = Int16(shotLocation.selectedSegmentIndex)
        pitRecord?.shotIsAccurate = shotIsAccurate.isOn
        pitRecord?.rating = Float(ratingLabel.text!)!
        pitRecord?.driveCoach = driveCoach.text!
        pitRecord?.practiceAmount = Int16(practiceSegControl.selectedSegmentIndex)
        pitRecord?.robotWeight = Int16(robotWeight.text!)!
        let imageData = UIImagePNGRepresentation(myImageView.image!) as NSData?
        pitRecord?.robotImage = imageData
        

        print("Pit Record is: \(pitRecord)")
        do {
            print("Save pit record: \(pitRecord))")
            try CoreDataStack.defaultStack.managedObjectContext.save()
        } catch let error as NSError {
            print("Could not save the pit report. \(error), \(error.userInfo)")
        }
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func photoFromLibrary(_ sender: UIBarButtonItem) {
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        picker.modalPresentationStyle = .popover
        present(picker, animated: true, completion: nil)
        picker.popoverPresentationController?.barButtonItem = sender
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
    
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = self.view.frame
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        let scaleImage = UIPinchGestureRecognizer(target: self,action:
            #selector(pinchImage))
        newImageView.addGestureRecognizer(scaleImage)
       

        self.view.addSubview(newImageView)
    }
    
    func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }
    func pinchImage(_ sender: UIPinchGestureRecognizer) {
        self.view.transform = self.view.transform.scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1
    }
    // MARK: - Picker
    // Keep image in the orienatation it was taken in 
    
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
        if (lowerTextFieldBeingEdited) {
            print("Lower text fields being edited so shift view up to avoid keyboard obstruction")
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                let keyboardHeight = keyboardSize.height
                if (view.frame.size.height-self.commentsStillWorkingOn.frame.origin.y) - self.commentsStillWorkingOn.frame.size.height < keyboardHeight{
                    moveValue = keyboardHeight - ((view.frame.size.height-self.commentsStillWorkingOn.frame.origin.y) - self.commentsStillWorkingOn.frame.size.height)
                    self.animateViewMoving(up: true, moveValue: moveValue )
                    moved = true
                }
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing")
        if (textField == robotWeight
            || textField == estimatedStorageVolumne
            || textField == commentsProud
            || textField == commentsStillWorkingOn)
            {
            print("beginning lower field editing")
            lowerTextFieldBeingEdited = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing")
        if (textField == robotWeight
            || textField == estimatedStorageVolumne
            || textField == commentsProud
            || textField == commentsStillWorkingOn)
        {
            print("ending lower field editing")
            lowerTextFieldBeingEdited = false
        }
        if moved == true {
            self.animateViewMoving(up: false, moveValue: moveValue )
            moved = false
        }
    }
    
    // MARK: - ImagePickerController
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("in imagePickerController")
        var  chosenImage = UIImage()
        chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        myImageView.contentMode = .scaleAspectFit //3
        myImageView.image = chosenImage //4
        dismiss(animated:true, completion: nil) //5
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    

}

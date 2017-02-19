//
//  TeamSummaryViewController.swift
//  FRCScout2017
//
//  Created by Sabrina Chen on 2/19/17.
//  Copyright © 2017 RoboTigers. All rights reserved.
//

import UIKit
import CoreData

class TeamSummaryViewController: UIViewController {

    var selectedTeamNumber = ""
    
    @IBOutlet weak var teamNum: UILabel!
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var driveCoach: UILabel!
    @IBOutlet weak var driveTrainType: UILabel!
    @IBOutlet weak var motorType: UISegmentedControl!
    @IBOutlet weak var overallSpeed: UILabel!
    @IBOutlet weak var robotWeight: UILabel!
    @IBOutlet weak var cheesecake: UILabel!
    @IBOutlet weak var storageVolume: UILabel!
    

    
    
    override func viewDidLoad() {
        print("In viewDidLoad of summary scene")
        print("selected team is \(selectedTeamNumber)")
        super.viewDidLoad()
        print("about to initialize pit Reports array")
        var pitReports: [PitReport] = []
        print("now get app delegate")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        print("now get context")
        let context = appDelegate.persistentContainer.viewContext
        print("now set fetch request")
        let fetchRequest = NSFetchRequest<PitReport>(entityName: "PitReport")
        print("Aboue to fetch for teamNumber: \(selectedTeamNumber)")
        fetchRequest.predicate = NSPredicate(format: "teamNumber == \(selectedTeamNumber)")
        print("teamNumber")
        do {
            pitReports = try context.fetch(fetchRequest)
            if pitReports.count > 0 {
                let existingPitReport = pitReports[0]
                driveCoach.text = existingPitReport.driveCoach
                driveTrainType.text = existingPitReport.driveTrainType
                motorType.selectedSegmentIndex = Int(Int16(existingPitReport.driveTrainMotorType))
                //overallSpeed
                //robotWeight.text = existingPitReport.robotWeight
                robotWeight.text = NSNumber(value: (existingPitReport.robotWeight)).stringValue
                
                
                
            }
            }catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
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

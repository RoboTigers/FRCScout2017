//
//  TeamChoicesViewController.swift
//  FRCScout2017
//
//  Created by Sharon Kass on 2/10/17.
//  Copyright © 2017 RoboTigers. All rights reserved.
//

import UIKit
import CoreData

class TeamChoicesViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var teamPicker: UIPickerView!
    
    var teams: [String] = []
    var selectedTeam = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        teamPicker.dataSource = self
        teamPicker.delegate = self
        title = "Teams"
    }

    override func viewWillAppear(_ animated: Bool) {
        refreshTeams()
        teamPicker.reloadAllComponents()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return teams.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return teams[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // If the user selects "New Team" from the picker then let him add a new team member to the list.
        // The UIPickerView is asyncrhonous so we must do any actions in confirmAction() rather than relying
        // on the calling code to wait.
        if (teams[row] == "New Team") {
            let alertController = UIAlertController(title: "Team Number?", message: "Please input team number:", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
                if let field = alertController.textFields![0] as UITextField? {
                    if self.teams.contains(field.text!) {
                        print("Team \(field.text!) already exists in the picker list")
                    } else {
                        print("Add \(field.text!) to picker list")
                        self.teams[row] = field.text!
                        self.selectedTeam = self.teams[row]
                        self.title = self.teams[row]
                        self.teams.append("New Team")
                        self.teams.sort()
                        pickerView.reloadAllComponents()
                    }
                } else {
                    print("User did not enter anything")
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
            alertController.addTextField { (textField) in
                textField.placeholder = "Team Number"
            }
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
        selectedTeam = teams[row]
        title = teams[row]
    }
    

    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (selectedTeam == "New Team") {
            displayErrorAlertWithOk("Please select a team")
            print("Do not perform segue since no team is selected")
            return false
        }
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destination = segue.destination
        if let navigationController = destination as? UINavigationController {
            destination = navigationController.visibleViewController!
        }
        
        if let segueIdentifier = segue.identifier {
            switch segueIdentifier {
            case "ShowPitReportSegue":
                // Send the selected team into the Pit Report scene
                if let pitReportViewController = destination as? PitViewController {
                    print ("ShowPitReportSegue segue")
                    pitReportViewController.selectedTeamNumber = selectedTeam
                }
                
            case "ShowTeamSegue":
                print("About to segue to team summary")
                if let teamSummaryViewController = destination as? TeamSummaryViewController {
                    teamSummaryViewController.selectedTeamNumber = selectedTeam
                }
            case "ShowMatchesForTeam":
                if let matchesController = destination as? MatchesViewController {
                    matchesController.selectedTeamNumber = selectedTeam
                }
            default:
                print ("Unknown segueIdentifier: \(segueIdentifier)")
                
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
    
    private func refreshTeams() {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            return
//        }
//        let context = appDelegate.persistentContainer.viewContext
        CoreDataStack.defaultStack.syncWithCompletion(nil)
        let fetchRequest = NSFetchRequest<PitReport>(entityName: "PitReport")
        var pitReports: [PitReport] = []
        do {
            pitReports = try CoreDataStack.defaultStack.managedObjectContext.fetch(fetchRequest)
            print("Retrieved \(pitReports.count) pitReports for picker")
            teams.removeAll()
            for report in pitReports {
                teams.append(report.teamNumber!)
            }
            teams.append("New Team")
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        teams.sort()
    }

}

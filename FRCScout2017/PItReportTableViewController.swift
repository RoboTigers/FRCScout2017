//
//  PItReportTableViewController.swift
//  FRCScout2017
//
//  Created by Sabrina Chen on 2/12/17.
//  Copyright © 2017 RoboTigers. All rights reserved.
//

import UIKit
import CoreData

class PItReportTableViewController: UITableViewController {
    
    var pitReports: [PitReport] = []
    var sortByWeight = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = "Team Pit Reports"
        refreshPitReports()
        self.tableView.reloadData()
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
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pitReports.count
    }
    
    private func refreshPitReports() {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            return
//        }
//        let context = appDelegate.persistentContainer.viewContext
        CoreDataStack.defaultStack.syncWithCompletion(nil)
        let fetchRequest = NSFetchRequest<PitReport>(entityName: "PitReport")
        if sortByWeight {
            let weightSort = NSSortDescriptor(key: "robotWeight", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
            var sortsArray: [NSSortDescriptor] = []
            sortsArray.append(weightSort)
            fetchRequest.sortDescriptors = sortsArray
        } else {
            let teamSort = NSSortDescriptor(key: "teamNumber", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
            var sortsArray: [NSSortDescriptor] = []
            sortsArray.append(teamSort)
            fetchRequest.sortDescriptors = sortsArray
        }
        do {
            pitReports = try CoreDataStack.defaultStack.managedObjectContext.fetch(fetchRequest)
            print("Retrieved \(pitReports.count) pitReport")
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pitRow", for: indexPath)
        var contact = ""
        if pitReports[indexPath.row].contactName != nil {
            contact = pitReports[indexPath.row].contactName!
        }
        cell.textLabel?.text = "Team \(pitReports[indexPath.row].teamNumber!) Contact: \(contact)  Weight: \(pitReports[indexPath.row].robotWeight)"
        return cell
    }

    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
//            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//                return
//            }
//            let context = appDelegate.persistentContainer.viewContext
            CoreDataStack.defaultStack.syncWithCompletion(nil)
            let pit = pitReports[indexPath.row]
            CoreDataStack.defaultStack.managedObjectContext.delete(pit)
            do {
                try CoreDataStack.defaultStack.managedObjectContext.save()
            } catch let error as NSError {
                print("Could not delete pit row. \(error), \(error.userInfo)")
            }
            
            // Update our global variable
            pitReports.remove(at: indexPath.row)
            
            // Delete the row from the table view
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    @IBAction func addPitReport(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Team Number?", message: "Please input team number:", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            if let field = alertController.textFields![0] as UITextField? {
                var alreadyExists = false
                for report in self.pitReports {
                    if report.teamNumber == field.text {
                        alreadyExists = true
                        self.displayErrorAlertWithOk("Team \(field.text!) already exists")
                        break
                    }
                }
                if !alreadyExists {
                    print("Add skelaton pit report for team \(field.text)")
//                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//                        return
//                    }
//                    let context = appDelegate.persistentContainer.viewContext
                    CoreDataStack.defaultStack.syncWithCompletion(nil)
                    //let skelatonPitRecord = PitReport(context: context)
                    let skelatonPitRecord : PitReport = NSEntityDescription.insertNewObject(forEntityName: "PitReport", into: CoreDataStack.defaultStack.managedObjectContext) as! PitReport
                    skelatonPitRecord.teamNumber = field.text
                    skelatonPitRecord.uniqueIdentifier = field.text
                    do {
                        try CoreDataStack.defaultStack.managedObjectContext.save()
                    } catch let error as NSError {
                        print("Could not save the skelaton pit report. \(error), \(error.userInfo)")
                    }
                    self.pitReports.append(skelatonPitRecord)
                    self.refreshPitReports()
                    self.tableView.reloadData()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destination = segue.destination
        if let navigationController = destination as? UINavigationController {
            destination = navigationController.visibleViewController!
        }
        
        if let segueIdentifier = segue.identifier {
            switch segueIdentifier {
            case "ShowSelectedPitReportSegue":
                // Send the selected team into the Pit Report scene
                if let pitReportViewController = destination as? PitViewController {
                let rowIndex = tableView.indexPathForSelectedRow!.row
                pitReportViewController.selectedTeamNumber = pitReports[rowIndex].teamNumber!
                }
            default:
                print ("Unknown segueIdentifier: \(segueIdentifier)")
                
            }
        }
    }


}

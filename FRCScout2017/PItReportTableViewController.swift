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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Hello")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("in viewWillAppear")
        refreshPitReports()
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pitReports.count
    }
    private func refreshPitReports() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<PitReport>(entityName: "PitReport")
        
        do {
            pitReports = try context.fetch(fetchRequest)
            print("Retrieved \(pitReports.count) pitReport")
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pitRow", for: indexPath)
        cell.textLabel?.text = pitReports[indexPath.row].teamNumber
        return cell
    }

    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let context = appDelegate.persistentContainer.viewContext
            let pit = pitReports[indexPath.row]
            context.delete(pit)
            do {
                try context.save()
            } catch let error as NSError {
                print("Could not delete pit row. \(error), \(error.userInfo)")
            }
            
            // Update our global variable
            pitReports.remove(at: indexPath.row)
            
            // Delete the row from the table view
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
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

//
//  MatchesViewController.swift
//  FRCScout2017
//
//  Created by Sharon Kass on 2/5/17.
//  Copyright © 2017 RoboTigers. All rights reserved.
//

import UIKit
import CoreData
import Ensembles

class MatchesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tournamentSegmentedControl: UISegmentedControl!
    @IBOutlet weak var matchesTableView: UITableView!
    
    // MARK: - Data model for this scene
    
    var matches: [MatchReport] = []
    
    var selectedTeamNumber = ""
    
    // MARK: - View containing the segmented control and the table view
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshMatches()
        matchesTableView.reloadData()
    }
    
    
    // MARK: - Unwind Actions from Add Report scene
    
    @IBAction func unwindFromMatchReportCancel(_ unwindSegue: UIStoryboardSegue) {
        print("Canceled")
    }

    
    // MARK: - Navigation
    
    @IBAction func addMatchReport(_ sender: UIBarButtonItem) {
        print("Add new match report")
        performSegue(withIdentifier: "AddMatchReportSegue", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destination = segue.destination
        if let navigationController = destination as? UINavigationController {
            destination = navigationController.visibleViewController!
        }
        
        if let segueIdentifier = segue.identifier {
            switch segueIdentifier {
            case "AddMatchReportSegue":
                // Send the selected tournament number into the AddMatch scene so the 
                // report can be saved to the proper tournament
                if let addMatchViewController = destination as? AddMatchViewController {
                    print ("AddMatchReportSegue segue")
                    addMatchViewController.selectedTournament = Int16(tournamentSegmentedControl.selectedSegmentIndex)
                }
                break
            case "ShowMatchSegue":
                // Send the selected match to the AddMatch scene which is really an add/update scene
                if let addMatchViewController = destination as? AddMatchViewController {
                    print ("ShowMatchSegue segue")
                    addMatchViewController.selectedTournament = Int16(tournamentSegmentedControl.selectedSegmentIndex)
                    let rowIndex = matchesTableView.indexPathForSelectedRow!.row
                    addMatchViewController.selectedMatchNumber = matches[rowIndex].matchNumber!
                    addMatchViewController.selectedTeamNumber = matches[rowIndex].teamNumber!
                }
                break
            default:
                print ("Unknown segueIdentifier: \(segueIdentifier)")
                
            }
        }
    }
 
    // MARK: - Table View
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return matches.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MatchReportCell", for: indexPath)
        let match = matches[indexPath.row]
        var result = ""
        switch(match.matchResult) {
        case 0:
            result = "Win"
            break
        case 1:
            result = "Lose"
            break
        case 2:
            result = "Tie"
            break
        default:
            print("Unknown match result, should never reach this!")
            break
        }
        cell.textLabel?.text = "Match# \(match.matchNumber!)\t\t\(result)"
        cell.detailTextLabel?.text = "Team # \(match.teamNumber!)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            CoreDataStack.defaultStack.syncWithCompletion(nil)
            let match = matches[indexPath.row]
            CoreDataStack.defaultStack.managedObjectContext.delete(match)
            do {
                try CoreDataStack.defaultStack.managedObjectContext.save()
            } catch let error as NSError {
                print("Could not delete match row. \(error), \(error.userInfo)")
            }
            
            // Update our global variable
            matches.remove(at: indexPath.row)
            
            // Delete the row from the table view
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            // Delete the row from the data source
//            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//                return
//            }
//            let context = appDelegate.persistentContainer.viewContext
//            let match = matches[indexPath.row]
//            context.delete(match)
//            do {
//                try context.save()
//            } catch let error as NSError {
//                print("Could not delete match row. \(error), \(error.userInfo)")
//            }
//            
//            // Update our global variable
//            matches.remove(at: indexPath.row)
//            
//            // Delete the row from the table view
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
//    }
    
    // MARK: - Data selection via segmented control

    /*
     * Fill the matches array with data from the data store for the selected tournament
     */
    @IBAction func chooseTournament(_ sender: UISegmentedControl) {
        refreshMatches()
        matchesTableView.reloadData()
    }
    
    private func refreshMatchesDoesNotUseSync() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<MatchReport>(entityName: "MatchReport")
        fetchRequest.predicate = NSPredicate(format: "tournament == \(tournamentSegmentedControl.selectedSegmentIndex)")
        let teamSort = NSSortDescriptor(key: "teamNumber", ascending:true)
        var sortsArray: [NSSortDescriptor] = []
        let matchSort = NSSortDescriptor(key: "matchNumber", ascending:true)
        sortsArray.append(matchSort)
        sortsArray.append(teamSort)
        fetchRequest.sortDescriptors = sortsArray
        
        do {
            matches = try context.fetch(fetchRequest)
            print("Retrieved \(matches.count) matches")
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    private func refreshMatches() {
        // SHARON DEBUG: CDESetCurrentLoggingLevel(CDELoggingLevel.verbose.rawValue)
        CoreDataStack.defaultStack.syncWithCompletion(nil)
        let fetchRequest = NSFetchRequest<MatchReport>(entityName: "MatchReport")
        if selectedTeamNumber == "" {
            fetchRequest.predicate = NSPredicate(format: "tournament == \(tournamentSegmentedControl.selectedSegmentIndex)")
        } else {
            fetchRequest.predicate = NSPredicate(format: "tournament == \(tournamentSegmentedControl.selectedSegmentIndex) AND teamNumber == \(selectedTeamNumber)")
        }
        let teamSort = NSSortDescriptor(key: "teamNumber", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        var sortsArray: [NSSortDescriptor] = []
        let matchSort = NSSortDescriptor(key: "matchNumber", ascending:true)
        sortsArray.append(matchSort)
        sortsArray.append(teamSort)
        fetchRequest.sortDescriptors = sortsArray
        
        do {
            matches = try CoreDataStack.defaultStack.managedObjectContext.fetch(fetchRequest)
            print("Retrieved \(matches.count) matches")
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}

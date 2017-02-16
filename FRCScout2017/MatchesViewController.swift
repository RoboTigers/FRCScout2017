//
//  MatchesViewController.swift
//  FRCScout2017
//
//  Created by Sharon Kass on 2/5/17.
//  Copyright © 2017 RoboTigers. All rights reserved.
//

import UIKit
import CoreData

class MatchesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tournamentSegmentedControl: UISegmentedControl!
    @IBOutlet weak var matchesTableView: UITableView!
    
    // MARK: - Data model for this scene
    
    var matches: [MatchReport] = []
    
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
        cell.textLabel?.text = "Match# \(match.matchNumber!)"
        cell.detailTextLabel?.text = "Team # \(match.teamNumber!)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let context = appDelegate.persistentContainer.viewContext
            let match = matches[indexPath.row]
            context.delete(match)
            do {
                try context.save()
            } catch let error as NSError {
                print("Could not delete match row. \(error), \(error.userInfo)")
            }
            
            // Update our global variable
            matches.remove(at: indexPath.row)
            
            // Delete the row from the table view
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: - Data selection via segmented control

    /*
     * Fill the matches array with data from the data store for the selected tournament
     */
    @IBAction func chooseTournament(_ sender: UISegmentedControl) {
    
        switch(tournamentSegmentedControl.selectedSegmentIndex) {
        case 0:
            print("Fetching matches for tournament to 0 (Regional)")
            break
        case 1:
            print("Fetching matches for tournament to 1 (LI)")
            break
        case 2:
            print("Fetching matches for tournament to 2 (Championship)")
            break
        default:
            print("No tournament setting, should never reach this!")
            break
        }
        
        refreshMatches()

        matchesTableView.reloadData()
    }
    
    private func refreshMatches() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<MatchReport>(entityName: "MatchReport")
        fetchRequest.predicate = NSPredicate(format: "tournament == \(tournamentSegmentedControl.selectedSegmentIndex)")
        let teamSort = NSSortDescriptor(key: "teamNumber", ascending:true)
        var sortsArray: [NSSortDescriptor] = []
        let matchSort = NSSortDescriptor(key: "matchNumber", ascending:true)
//        let matchSort = NSSortDescriptor(key: "Match", ascending: true, selector: NSLocalizedString ("Match", tableName: String?, bundle: Bundle, value: String, comment: String))
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
}

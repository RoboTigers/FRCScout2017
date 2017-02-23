//
//  BestViewController.swift
//  FRCScout2017
//
//  Created by Sharon Kass on 2/23/17.
//  Copyright © 2017 RoboTigers. All rights reserved.
//

import UIKit
import CoreData
import Ensembles

class BestViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var teamArray: [TeamStats] = []
    
    var selectedTournament = 0

    @IBOutlet weak var skill: UISegmentedControl!
    @IBOutlet weak var bestTableView: UITableView!
    
    @IBAction func skillAction(_ sender: UISegmentedControl) {
        refreshData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("selectedTournament = \(selectedTournament)")
        title = "Best At Skill"
        refreshData()
    }
    
    // MARK: - Table view data source
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BestAtTeamCell", for: indexPath)
        cell.textLabel?.text = "Team \(teamArray[indexPath.row].teamNumber)    Ave Low: \(teamArray[indexPath.row].avergeNumberFuelLow) High: \(teamArray[indexPath.row].averageNumberFuelHigh) Gears \(teamArray[indexPath.row].averageNumberGears) Hangs \(teamArray[indexPath.row].averageNumberClimbs)"
        return cell
    }
    
    
    // MARK: - Refresh data model for this scene
    
    private func refreshData() {
        // We will read all the match data into the matches array and then fill in a team dictionary
        // aggregating the stats as we go. Then we sort the dictionary according to the segmented control
        // for proper display in the table view.
        var teamDictionary: [String: TeamStats] = [:]
        var matches: [MatchReport] = []
        
        // First grab all matches for the selcted tournament into matches array
        //        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        //            return
        //        }
        //        let context = appDelegate.persistentContainer.viewContext
        CoreDataStack.defaultStack.syncWithCompletion(nil)
        let fetchRequest = NSFetchRequest<MatchReport>(entityName: "MatchReport")
        fetchRequest.predicate = NSPredicate(format: "tournament == \(selectedTournament)")
        do {
            //matches = try context.fetch(fetchRequest)
            matches = try CoreDataStack.defaultStack.managedObjectContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        // Next we update the team dictionary from the matches
        for match in matches {
            if (teamDictionary[match.teamNumber!] != nil) {
                print("update dictionary")
                let teamFromDictionary = teamDictionary[match.teamNumber!]
                teamFromDictionary?.numberOfMatchesPlayed = (teamFromDictionary?.numberOfMatchesPlayed)! + 1
                teamFromDictionary?.totalNumberFuelLow = (teamFromDictionary?.totalNumberFuelLow)! + match.fuelLow
                teamFromDictionary?.totalNumberFuelHigh = (teamFromDictionary?.totalNumberFuelHigh)! + match.fuelHigh
                teamFromDictionary?.totalNumberGears = (teamFromDictionary?.totalNumberGears)! + match.gears
                if match.hang {
                    teamFromDictionary?.totalNumberClimbs = (teamFromDictionary?.totalNumberClimbs)! + 1
                }
                teamFromDictionary?.avergeNumberFuelLow = Double((teamFromDictionary?.totalNumberFuelLow)!) / Double((teamFromDictionary?.numberOfMatchesPlayed)!)
                teamFromDictionary?.averageNumberFuelHigh = Double((teamFromDictionary?.totalNumberFuelHigh)!) / Double((teamFromDictionary?.numberOfMatchesPlayed)!)
                teamFromDictionary?.averageNumberGears = Double((teamFromDictionary?.totalNumberGears)!) / Double((teamFromDictionary?.numberOfMatchesPlayed)!)
                teamFromDictionary?.averageNumberClimbs = Double((teamFromDictionary?.totalNumberClimbs)!) / Double((teamFromDictionary?.numberOfMatchesPlayed)!)
            } else {
                print("create new key in dictionary")
                let newTeam: TeamStats = TeamStats()
                newTeam.teamNumber = match.teamNumber!
                newTeam.numberOfMatchesPlayed = 1
                newTeam.totalNumberFuelLow = match.fuelLow
                newTeam.totalNumberFuelHigh = match.fuelHigh
                newTeam.totalNumberGears = match.gears
                if match.hang {
                    newTeam.totalNumberClimbs = 1
                } else {
                    newTeam.totalNumberClimbs = 0
                }
                newTeam.avergeNumberFuelLow = Double(newTeam.totalNumberFuelLow)
                newTeam.averageNumberFuelHigh = Double(newTeam.totalNumberFuelHigh)
                newTeam.averageNumberGears = Double(newTeam.totalNumberGears)
                newTeam.averageNumberClimbs = Double(newTeam.totalNumberClimbs)
                teamDictionary.updateValue(newTeam, forKey: match.teamNumber!)
            }
        }
        
        // Next we sort the dictionary according to the segmented control selection (Low, High, Gears, Climb)
        //let sortedBy = teamDictionary.sorted{ $0.value.avergeNumberFuelLow > $1.value.avergeNumberFuelLow }
        var sortedBy = teamDictionary.sorted{ $0.value.avergeNumberFuelLow > $1.value.avergeNumberFuelLow}  // default sort order
        switch(skill.selectedSegmentIndex) {
            case 0:
                print("Order by Fuel Low")
                sortedBy = teamDictionary.sorted{ $0.value.avergeNumberFuelLow > $1.value.avergeNumberFuelLow }
                break
            case 1:
                print("Order by Fuel High")
                sortedBy = teamDictionary.sorted{ $0.value.averageNumberFuelHigh > $1.value.averageNumberFuelHigh }
                break
            case 2:
                print("Order by Gears")
                sortedBy = teamDictionary.sorted{ $0.value.averageNumberGears > $1.value.averageNumberGears }
                break
            case 3:
                print("Order by Climbing")
                sortedBy = teamDictionary.sorted{ $0.value.averageNumberClimbs > $1.value.averageNumberClimbs }
                break
            default:
                print("No sort setting, should never reach this!")
                break
        }
        
        // Next we populate the teams array which is used by the table view
        teamArray.removeAll()
        for (key, value) in sortedBy {
            print("Key: \(key), value: \(value)")
            teamArray.append(value)
        }
        
        // Finally we reload the table view so that it displays its rows based on the above newly
        // calculated teams array
        bestTableView.reloadData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destination = segue.destination
        if let navigationController = destination as? UINavigationController {
            destination = navigationController.visibleViewController!
        }
        
        if let segueIdentifier = segue.identifier {
            switch segueIdentifier {
            case "BestAtTeamSummarySegue":
                print("About to segue to team summary")
                if let teamSummaryViewController = destination as? TeamSummaryViewController {
                    let rowIndex = bestTableView.indexPathForSelectedRow!.row
                    teamSummaryViewController.selectedTeamNumber = teamArray[rowIndex].teamNumber
                }
            default:
                print ("Unknown segueIdentifier: \(segueIdentifier)")
                
            }
        }
    }

}

//
//  WinningViewController.swift
//  FRCScout2017
//
//  Created by Sharon Kass on 3/3/17.
//  Copyright © 2017 RoboTigers. All rights reserved.
//

import UIKit
import CoreData
import Ensembles

class WinningViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var teamArray: [TeamStats] = []
    
    var selectedTournament = 0

    @IBOutlet weak var segOutlet: UISegmentedControl!
    
    @IBAction func segAction(_ sender: UISegmentedControl) {
        refreshData()
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshData()
    }

    override func viewWillAppear(_ animated: Bool) {
        title = "Best Winners / Scorers"
    }
    
    // MARK: - Table view data source
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WinningCell", for: indexPath)
        let formattedWinningPercentage = String(format: "%.1f", teamArray[indexPath.row].winningPercentage * 100)
        cell.textLabel?.text = "Team \(teamArray[indexPath.row].teamNumber)    Winning: \(formattedWinningPercentage)% "
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
                if match.matchResult == 0 {
                    teamFromDictionary?.numberWins = (teamFromDictionary?.numberWins)! + 1
                }
                teamFromDictionary?.winningPercentage = Double((teamFromDictionary?.numberWins)!) / Double((teamFromDictionary?.numberOfMatchesPlayed)!)

            } else {
                print("create new key in dictionary")
                let newTeam: TeamStats = TeamStats()
                newTeam.teamNumber = match.teamNumber!
                newTeam.numberOfMatchesPlayed = 1
                if match.matchResult == 0 {
                    newTeam.numberWins = 1
                } else {
                    newTeam.numberWins = 0
                }
                newTeam.winningPercentage = Double(newTeam.numberWins)
                teamDictionary.updateValue(newTeam, forKey: match.teamNumber!)
            }
        }
        
        // Next we sort the dictionary according to the segmented control selection (Wins, Auto, Tele)
        var sortedBy = teamDictionary.sorted{ $0.value.winningPercentage > $1.value.winningPercentage}  // default sort order
        switch(segOutlet.selectedSegmentIndex) {
        case 0:
            print("Order by Winning Percentage")
            sortedBy = teamDictionary.sorted{ $0.value.winningPercentage > $1.value.winningPercentage }
            break
        case 1:
            print("Order by Can Play Effective Defense")
            sortedBy = teamDictionary.sorted{ $0.value.averageWeightedDefensePlayedAndEffective > $1.value.averageWeightedDefensePlayedAndEffective }
            break
        case 2:
            print("Order by Penalty Percentage")
            sortedBy = teamDictionary.sorted{ $0.value.averagePenalty > $1.value.averagePenalty }
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
        tableView.reloadData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destination = segue.destination
        if let navigationController = destination as? UINavigationController {
            destination = navigationController.visibleViewController!
        }
        
        if let segueIdentifier = segue.identifier {
            switch segueIdentifier {
            case "WinScoreTeamSegue":
                print("About to segue to team summary")
                if let teamSummaryViewController = destination as? TeamSummaryViewController {
                    let rowIndex = tableView.indexPathForSelectedRow!.row
                    teamSummaryViewController.selectedTeamNumber = teamArray[rowIndex].teamNumber
                }
            default:
                print ("Unknown segueIdentifier: \(segueIdentifier)")
                
            }
        }
    }
    

}

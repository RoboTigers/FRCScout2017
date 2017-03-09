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
        title = "Best By Result"
    }
    
    // MARK: - Table view data source
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WinningCell", for: indexPath)
        let formattedWinningPercentage = String(format: "%.1f", teamArray[indexPath.row].winningPercentage * 100)
        let formattedPenaltyPercentage = String(format: "%.1f", teamArray[indexPath.row].averagePenalty * 100)
        cell.textLabel?.text = "Team \(teamArray[indexPath.row].teamNumber)    Win Percentage: \(formattedWinningPercentage)% Defensive Ability: \(teamArray[indexPath.row].averageWeightedDefensePlayedAndEffective)  Penalty Percentage: \(formattedPenaltyPercentage)%"
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
                teamFromDictionary?.totalWeightedDefensePlayedAndEffective = (teamFromDictionary?.totalWeightedDefensePlayedAndEffective)! +  calculateWeightedDefenseValue(playedValue: match.defensePlayed, playedWeight: match.defensePlayedLevel)
                teamFromDictionary?.averageWeightedDefensePlayedAndEffective = Double((teamFromDictionary?.totalWeightedDefensePlayedAndEffective)!) / Double((teamFromDictionary?.numberOfMatchesPlayed)!)
                if match.penalty {
                    teamFromDictionary?.totalPenalty = (teamFromDictionary?.totalPenalty)! + 1
                }
                teamFromDictionary?.averagePenalty = Double((teamFromDictionary?.totalPenalty)!) / Double((teamFromDictionary?.numberOfMatchesPlayed)!)


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
                newTeam.totalWeightedDefensePlayedAndEffective = calculateWeightedDefenseValue(playedValue: match.defensePlayed, playedWeight: match.defensePlayedLevel)
                newTeam.averageWeightedDefensePlayedAndEffective = Double(newTeam.totalWeightedDefensePlayedAndEffective)
                if match.penalty {
                    newTeam.totalPenalty = 1
                } else {
                    newTeam.totalPenalty = 0
                }
                newTeam.averagePenalty = Double(newTeam.totalPenalty)
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
    
    /*
     * Calculate a value to indicate how much and how well a team played defense during a match.
     * Since segmented control index values start at 0 the weighted value of any defense which is
     * defined as "None" or as "Ineffective" will be 0. That is, no "points" are awarded for 
     * ineffective defense. The effectiveness of the played defense acts as a weight factor 
     * doubling the playedValue if that defense played was excellent.
     *    Played: 
     *      None = 0
     *      Some = 1
     *      A lot = 2
     *    Effectiveness:
     *      Ineffective = 0
     *      Average = 1
     *      Excellent = 2
     */
    func calculateWeightedDefenseValue(playedValue: Int16, playedWeight: Int16) -> Int16 {
        return (playedValue * playedWeight)
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

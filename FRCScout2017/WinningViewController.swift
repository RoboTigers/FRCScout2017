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
        let formattedAutoScoring = String(format: "%.1f", teamArray[indexPath.row].averageNumberAutoScore)
        let formattedTeleScoring = String(format: "%.1f", teamArray[indexPath.row].averageNumberTeleScore)
        cell.textLabel?.text = "Team \(teamArray[indexPath.row].teamNumber)    Winning: \(formattedWinningPercentage)% Average Auto: \(formattedAutoScoring) Teleop: \(formattedTeleScoring)"
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
                teamFromDictionary?.totalNumberAutoScore = (teamFromDictionary?.totalNumberAutoScore)! + match.autoScore
                teamFromDictionary?.totalNumberTeleScore = (teamFromDictionary?.totalNumberTeleScore)! + match.teleScore
                if match.matchResult == 0 {
                    teamFromDictionary?.numberWins = (teamFromDictionary?.numberWins)! + 1
                }
                teamFromDictionary?.winningPercentage = Double((teamFromDictionary?.numberWins)!) / Double((teamFromDictionary?.numberOfMatchesPlayed)!)
                teamFromDictionary?.averageNumberAutoScore = Double((teamFromDictionary?.totalNumberAutoScore)!) / Double((teamFromDictionary?.numberOfMatchesPlayed)!)
                teamFromDictionary?.averageNumberTeleScore = Double((teamFromDictionary?.totalNumberTeleScore)!) / Double((teamFromDictionary?.numberOfMatchesPlayed)!)

            } else {
                print("create new key in dictionary")
                let newTeam: TeamStats = TeamStats()
                newTeam.teamNumber = match.teamNumber!
                newTeam.numberOfMatchesPlayed = 1
                newTeam.totalNumberAutoScore = match.autoScore
                newTeam.totalNumberTeleScore = match.teleScore
                if match.matchResult == 0 {
                    newTeam.numberWins = 1
                } else {
                    newTeam.numberWins = 0
                }
                newTeam.winningPercentage = Double(newTeam.numberWins)
                newTeam.averageNumberAutoScore = Double(newTeam.totalNumberAutoScore)
                newTeam.averageNumberTeleScore = Double(newTeam.totalNumberTeleScore)
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
            print("Order by Auto Scoring Average")
            sortedBy = teamDictionary.sorted{ $0.value.averageNumberAutoScore > $1.value.averageNumberAutoScore }
            break
        case 2:
            print("Order by Teleop Scoring Average")
            sortedBy = teamDictionary.sorted{ $0.value.averageNumberTeleScore > $1.value.averageNumberTeleScore }
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
    


}

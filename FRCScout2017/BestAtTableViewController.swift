//
//  BestAtTableViewController.swift
//  FRCScout2017
//
//  Created by Sharon Kass on 2/19/17.
//  Copyright © 2017 RoboTigers. All rights reserved.
//

import UIKit
import CoreData

class BestAtTableViewController: UITableViewController {
    
    var teamArray: [TeamStats] = []
    //var teamDictionary: NSDictionary = [String:TeamStats]
//    var matches: [MatchReport] = []
//    
//    let teamDictionary: NSDictionary = [
//        "teamNumber" : String,
//        "stats" : TeamStats
//    ]
    
    var selectedTournament = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        print("selectedTournament = \(selectedTournament)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BestTeamCell", for: indexPath)
        cell.textLabel?.text = teamArray[indexPath.row].teamNumber  //TODO: Make a nicer cell
        return cell
    }
 
    private func refreshData() {
        // First grab all matches for the selcted tournament into matches array
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
//        let fetchRequest = NSFetchRequest<MatchReport>(entityName: "MatchReport")
//        
//        do {
//            matches = try context.fetch(fetchRequest)
//        } catch let error as NSError {
//            print("Could not fetch. \(error), \(error.userInfo)")
//        }
//        
//        // Next we fill in team dictionary from the matches
//        for match in matches {
//            if teamDictionary[match.teamNumber] {
//                print("update dictionary")
//            } else {
//                print("create new key in dictionary")
//            }
//        }
        
        // Next we re-order the dictionary according to the segmented control selection (Low, High, Gears, Climb)
        // into a teams array to be used by the table view controller requirements
        
        // Finally we reload the table view
        tableView.reloadData()
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

//
//  AnalyticsLandingViewController.swift
//  FRCScout2017
//
//  Created by Sharon Kass on 2/19/17.
//  Copyright © 2017 RoboTigers. All rights reserved.
//

import UIKit

class AnalyticsLandingViewController: UIViewController {
    

    @IBOutlet weak var tournamentSegmentedControl: UISegmentedControl!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Analytics"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destination = segue.destination
        if let navigationController = destination as? UINavigationController {
            destination = navigationController.visibleViewController!
        }
        
        if let segueIdentifier = segue.identifier {
            switch segueIdentifier {
            case "ShowBestSegue":
                // Send the selected tournament to the Best-At scene
                if let bestTableViewController = destination as? BestAtTableViewController {
                    bestTableViewController.selectedTournament = tournamentSegmentedControl.selectedSegmentIndex
                }
            default:
                print ("Unknown segueIdentifier: \(segueIdentifier)")
                
            }
        }
    }
}

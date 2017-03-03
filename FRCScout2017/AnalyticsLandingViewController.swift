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
            case "ShowBestAtSegue":
                // Send the selected tournament to the Best-At scene
                if let bestViewController = destination as? BestViewController {
                    bestViewController.selectedTournament = tournamentSegmentedControl.selectedSegmentIndex
                }
                break
            case "cheesecakeSegue":
                if let pitReportTVC = destination as? PItReportTableViewController {
                    pitReportTVC.sortByWeight = true
                }
                break
            default:
                print ("Unknown segueIdentifier: \(segueIdentifier)")
                
            }
        }
    }
}

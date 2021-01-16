//
//  RunLogVC.swift
//  AppRunner
//
//  Created by leslie on 1/16/21.
//

import UIKit
import MapKit

// MARK: - LocationVC
class RunLogVC: LocationVC {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToShowRouteVC" {
            let showRoutVC = segue.destination as! ShowRouteVC
            // TODO: - 01
//            showRoutVC.locations = locations
        }
    }
    
}

// MARK: - Table View Data Source
extension RunLogVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}

// MARK: - Table View Delegate
extension RunLogVC: UITableViewDelegate {
    
}

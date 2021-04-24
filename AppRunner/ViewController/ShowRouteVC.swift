//
//  ShowRouteVC.swift
//  AppRunner
//
//  Created by leslie on 1/16/21.
//

import UIKit
import MapKit
import CoreData

// MARK: - Variables and Propeties - Core Data
//var coreDataStack: AppDelegate!
//var context: NSManagedObjectContext!
//
//var locFetchRequest: NSFetchRequest<Location>?
//var runFetchRequest: NSFetchRequest<Run>?
//
//var asyncLocFetchRequest: NSAsynchronousFetchRequest<Location>?
//var asyncRunFetchRequest: NSAsynchronousFetchRequest<Run>?
var test: Int = 0

var locations: [Location] = []
var runs: [Run] = []
var selectedRun: Run?

// MARK: - ShowRouteVC
class ShowRouteVC: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: IBActions
    @IBAction func userCenterBtnPressed(_ sender: Any) {
        
    }

}

// MARK: - MKMapViewDelegate
extension ShowRouteVC: MKMapViewDelegate {
    
}

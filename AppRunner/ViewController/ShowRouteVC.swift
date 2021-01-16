//
//  ShowRouteVC.swift
//  AppRunner
//
//  Created by leslie on 1/16/21.
//

import UIKit
import MapKit

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

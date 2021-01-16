//
//  BeginRunVC.swift
//  AppRunner
//
//  Created by leslie on 1/16/21.
//

import UIKit
import MapKit

// MARK: - LocationVC
class BeginRunVC: LocationVC {
    
    // MARK: - Constants
    let lcationVC = LocationVC()

    // MARK: - IBOutlet
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lastRunBGView: UIView!
    @IBOutlet weak var lastRunCloseBtn: UIButton!
    @IBOutlet weak var lastRunDateLbl: UILabel!
    @IBOutlet weak var lastRunPaceLbl: UILabel!
    @IBOutlet weak var lastRunSpeedLbl: UILabel!
    @IBOutlet weak var lastRunDurationLbl: UILabel!
    @IBOutlet weak var lastRunDistanceLbl: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // MARK: - IBActions
    @IBAction func locationCenterBtnPressed(_ sender: Any) {
        
    }
    
    @IBAction func lastRunCloseBtnPressed(_ sender: Any) {
        
    }

}

// MARK: - MKMapViewDelegate
extension BeginRunVC: MKMapViewDelegate {
    
}

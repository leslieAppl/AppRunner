//
//  CurrentRunVC.swift
//  AppRunner
//
//  Created by leslie on 1/16/21.
//

import UIKit
import MapKit
import CoreData

// MARK: - LocationVC
class CurrentRunVC: LocationVC {

    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var swipeBGImageView: UIImageView!
    @IBOutlet weak var sliderImageView: UIButton!
    @IBOutlet weak var durrationLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    
    @IBOutlet weak var currentPaceLbl: UILabel!
    @IBOutlet weak var currentSpeedLbl: UILabel!
    
    @IBOutlet weak var avePaceLbl: UILabel!
    @IBOutlet weak var aveSpeedLbl: UILabel!
    
    @IBOutlet weak var pauseBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    // MARK: - IBActions
    @IBAction func pauseBtnPressed(_ sender: Any) {
        
    }

}

// MARK: - MKMapViewDelegate
extension CurrentRunVC: MKMapViewDelegate {
    
}

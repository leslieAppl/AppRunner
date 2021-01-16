//
//  ViewController.swift
//  AppRunner
//
//  Created by leslie on 1/16/21.
//
import UIKit
import MapKit
import CoreLocation

// MARK: - UIViewController
class LocationVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

}

// MARK: - CLLocationManagerDelegate
extension LocationVC: CLLocationManagerDelegate {
    
}

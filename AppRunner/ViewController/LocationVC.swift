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
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func checkLocationServices() {
        // Check device's setting > private > location services that if it's truned on.
        if CLLocationManager.locationServicesEnabled() {
            
        }
        else {
            // Show alert that let the user know they have to turn this on.
        }
    }
    
    func setupLocationManager() {
        // Basic Setting...
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10
        
        // Background Mode Setting...
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.showsBackgroundLocationIndicator = true
        
        // default setting
//        locationManager.distanceFilter = kCLDistanceFilterNone
        
        // TODO: Also use a timer?
    }
    
    func checkLocationAuthorization() {
        // In a switch statement for readability each function involves no more 5 implementations.
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            // Do Map Stuff
            break
        case .denied:
            // Show alert instructing them how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Show an alert letting them know what's up
            break
        case .authorizedAlways:
            break
        @unknown default:
            fatalError()
        }
    }

}

// MARK: - CLLocationManagerDelegate
extension LocationVC: CLLocationManagerDelegate {
    // Tells the delegate its authorization status when the app creates the location manager and when the authorization status changes.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

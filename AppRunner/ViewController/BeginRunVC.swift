//
//  BeginRunVC.swift
//  AppRunner
//
//  Created by leslie on 1/16/21.
//

import UIKit
import MapKit
import CoreData

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

    // MARK: - Variables And Properties
    var context: NSManagedObjectContext!
    var locations: [NSManagedObject] = []
    var runs: [NSManagedObject] = []
    
    // MARK: - View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Core Data
        let app = UIApplication.shared
        let appDelegate = app.delegate as! AppDelegate
        self.context = appDelegate.context
        print("BeginRunVC: \(self.context)")

        // Core Location
        checkLocationServices()
        
        // Map View
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // MARK: - Internal Methods
    func setupMapView() {
        
        if let polyline = addLastRunToMap() {
            
            if mapView.overlays.count > 0 {
                mapView.removeOverlays(mapView.overlays)
            }
            
            // this method will call: mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer at MKOverlay protocol by the map view delegate.
            mapView.addOverlay(polyline)
            
            lastRunBGView.isHidden = false
        }
        else {
            
            lastRunBGView.isHidden = true
            centerMapOnUserLocation()
        }
    }
    
    func addLastRunToMap() -> MKPolyline? {
        
        // TODO: - Get last run from core data
//        guard let lastRun = context else { return <#return value#> }
        
        var coordinates = [CLLocationCoordinate2D]()
        
        return MKPolyline(coordinates: &coordinates, count: 0)
    }
    
    func centerMapOnUserLocation() {
        
        mapView.userTrackingMode = .follow
        let coordinateRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: - IBActions
    @IBAction func locationCenterBtnPressed(_ sender: Any) {
        centerMapOnUserLocation()
    }
    
    @IBAction func lastRunCloseBtnPressed(_ sender: Any) {
        lastRunBGView.isHidden = true
        centerMapOnUserLocation()
    }

}

// MARK: - MKMapViewDelegate
extension BeginRunVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(overlay: polyline)
        renderer.strokeColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        renderer.lineWidth = 3
        return renderer
    }
}

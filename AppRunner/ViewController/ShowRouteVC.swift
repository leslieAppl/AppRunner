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

// MARK: - ShowRouteVC
class ShowRouteVC: UIViewController {

    var locations: [Location] = []
    var selectedRun: Run?

    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: - Map View
        mapView.delegate = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let sr = self.selectedRun,
              let rl = sr.locations
        else { return }
        
        for location in rl {
            let loc = location as! Location
            
            self.locations.append(loc)
        }
        
        setupMapView()
//        setupMapView2()
    }
    
    // MARK: IBActions
    @IBAction func userCenterBtnPressed(_ sender: Any) {
        
        centerMapOnUserLocation()
    }
    
    // MARK: - Internal Methods - Map View Methods
    func setupMapView() {
        print(#function)

        // Map View
        self.mapView.userTrackingMode = .none
        self.mapView.setRegion(centerMapOnSelectedRoute(locations: locations), animated: true)
        
        // Polyline
        var coordinates = [CLLocationCoordinate2D]()

        for loc in self.locations {

            coordinates.append(CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude))

        }
        
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        print(">> polyline: \(polyline)")
        
        if mapView.overlays.count > 0 {
            mapView.removeOverlays(mapView.overlays)
        }

        // this method will call: mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer at MKOverlay protocol by the map view delegate.
        self.mapView.addOverlay(polyline)

    }

    func centerMapOnSelectedRoute(locations: [Location]) -> MKCoordinateRegion {
        print(#function)
        
        guard let initialLoc = locations.first else { return MKCoordinateRegion() }
        
        var minLat = initialLoc.latitude
        var minLng = initialLoc.longitude
        var maxLat = minLat
        var maxLng = minLng
        
        for location in locations {
            minLat = min(minLat, location.latitude)
            minLng = min(minLng, location.longitude)
            maxLat = max(maxLat, location.latitude)
            maxLng = max(maxLng, location.longitude)
        }
        
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: (minLat+maxLat)/2, longitude: (minLng+maxLng)/2), span: MKCoordinateSpan(latitudeDelta: (maxLat-minLat)*1.4, longitudeDelta: (maxLng-minLng)*1.4))
    }
    
    func centerMapOnUserLocation() {
        print(#function)
        
        mapView.userTrackingMode = .follow
        let coordinateRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}

// MARK: - MKMapViewDelegate
extension ShowRouteVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        print(#function)
        
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(overlay: polyline)
        renderer.strokeColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        renderer.lineWidth = 3
        return renderer
    }
}


//
//  BeginRunVC.swift
//  AppRunner
//
//  Created by leslie on 1/16/21.
//

import UIKit
import MapKit
import CoreData
import CoreLocation
// MARK: - LocationVC
class BeginRunVC: LocationVC {
    
    // MARK: - Constants
    let lcationVC = LocationVC()
    
    // MARK: - Variables and Propeties - Core Data
    var coreDataStack: AppDelegate!
    var context: NSManagedObjectContext!
    
    var locFetchRequest: NSFetchRequest<Location>?
    var runFetchRequest: NSFetchRequest<Run>?
    
    var asyncLocFetchRequest: NSAsynchronousFetchRequest<Location>?
    var asyncRunFetchRequest: NSAsynchronousFetchRequest<Run>?
    
    var locations: [Location] = []
    var runs: [Run] = []
    var lastRun: Run?
    
    /// NSSortDescriptor
    lazy var dateSortDescriptor: NSSortDescriptor = {
        return NSSortDescriptor(key: #keyPath(Run.date), ascending: true)
    }()
    
    // MARK: - Variables and Propeties - Map & Run
//    var coordinates = [CLLocationCoordinate2D]()

    // MARK: - IBOutlet
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lastRunBGView: UIView!
    @IBOutlet weak var lastRunCloseBtn: UIButton!
    @IBOutlet weak var lastRunDateLbl: UILabel!
    @IBOutlet weak var lastRunPaceLbl: UILabel!
    @IBOutlet weak var lastRunSpeedLbl: UILabel!
    @IBOutlet weak var lastRunDurationLbl: UILabel!
    @IBOutlet weak var lastRunDistanceLbl: UILabel!
    
    // MARK: - View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        
        // MARK: - Core Data
        let app = UIApplication.shared
        guard let appDelegate = app.delegate as? AppDelegate else { return }
        
        self.coreDataStack = appDelegate
        self.context = coreDataStack.context
        
        /// Print simulater sotre url.
        guard let storeURL = context.persistentStoreCoordinator?.persistentStores.first?.url else { return }
        print("Simulator store url: \(String(describing: storeURL))")
        
        /// NSAsynchronousFetchRequest: Performing fetches in the background
        asyncRFR()
//        asyncLFR()
        
        // MARK: - Core Location
        checkLocationServices()
        
        // MARK: - Map View
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
                
        // Test

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(#function)
        
        setupMapView()
    }
    
    // MARK: - Internal Methods - Core Data
    func fetchLastRun() {
        print(#function)
        
        guard let runFetch = self.runFetchRequest else { return }
        runFetch.sortDescriptors = [self.dateSortDescriptor]
        
        do {
            
            let runs = try context.fetch(runFetch)
            self.lastRun = runs.last
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
        
    // MARK: - Internal Methods - Map View Methods
    func setupMapView() {
        print(#function)
        
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
        print(#function)
        
        // TODO: - Get last run from core data
        fetchLastRun()
        
        guard let lastRun = self.lastRun else { return nil }

        // Begin Run UI
        lastRunDateLbl.text = lastRun.date?.formatDateToString()
        lastRunPaceLbl.text = "\(Int(lastRun.avePace).formatTimeDurationToString()) H/Km"
        lastRunSpeedLbl.text = "\(lastRun.aveSpeed.metersToKmForString(places: 2)) Km/H"
        lastRunDurationLbl.text = "\(Int(lastRun.duration).formatTimeDurationToString())"
        lastRunDistanceLbl.text = "\(lastRun.distance.metersToKmForString(places: 2)) Km"
        
        // Polyline
        var coordinates = [CLLocationCoordinate2D]()
        if let locs = lastRun.locations {
            
            for location in locs {
                let loc = location as! Location
                
                // MARK: - TODO: Drawing Polyline
                coordinates.append(CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude))

            }
            
            mapView.userTrackingMode = .none
            mapView.setRegion(centerMapOnPrevRoute(locations: locs), animated: true)
        }
        
        return MKPolyline(coordinates: &coordinates, count: coordinates.count)
    }
    
    func centerMapOnUserLocation() {
        print(#function)
        
        mapView.userTrackingMode = .follow
        let coordinateRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func centerMapOnPrevRoute(locations: NSOrderedSet) -> MKCoordinateRegion {
        print(#function)
        
        guard let initialLoc = locations.firstObject as? Location else { return MKCoordinateRegion() }
        
        var minLat = initialLoc.latitude
        var minLng = initialLoc.longitude
        var maxLat = minLat
        var maxLng = minLng
        
        for location in locations {
            let loc = location as! Location
            minLat = min(minLat, loc.latitude)
            minLng = min(minLng, loc.longitude)
            maxLat = max(maxLat, loc.latitude)
            maxLng = max(maxLng, loc.longitude)
        }
        
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: (minLat+maxLat)/2, longitude: (minLng+maxLng)/2), span: MKCoordinateSpan(latitudeDelta: (maxLat-minLat)*1.4, longitudeDelta: (maxLng-minLng)*1.4))
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
        print(#function)
        
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(overlay: polyline)
        renderer.strokeColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        renderer.lineWidth = 3
        return renderer
    }
}

// MARK: - Core Data Helper
extension BeginRunVC {
    
    // MARK: - NSAsynchronousFetchRequest
    func asyncRFR() {
        
        /// NSAsynchronousFetchRequest: Performing fetches in the background
        let rfr: NSFetchRequest<Run> = Run.fetchRequest()
        self.runFetchRequest = rfr
        self.asyncRunFetchRequest = NSAsynchronousFetchRequest(fetchRequest: rfr, completionBlock: {[unowned self] (result: NSAsynchronousFetchResult) in
            
            guard let runs = result.finalResult else { return }
            self.runs = runs
        })
        
        do {
            guard let arfr = self.asyncRunFetchRequest else { return }
            
            try context.execute(arfr)
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }

    func asyncLFR() {
        
        /// NSAsynchronousFetchRequest: Performing fetches in the background
        let lfr: NSFetchRequest<Location> = Location.fetchRequest()
        self.locFetchRequest = lfr
        self.asyncLocFetchRequest = NSAsynchronousFetchRequest(fetchRequest: lfr, completionBlock: {[unowned self] (result: NSAsynchronousFetchResult) in
            
            guard let locs = result.finalResult else { return }
            self.locations = locs
        })
                
        do {
            guard let alfr = self.asyncLocFetchRequest else { return }
            
            try context.execute(alfr)
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
}

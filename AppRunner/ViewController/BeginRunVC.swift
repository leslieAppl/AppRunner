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
    
    // Holding your fetch request
    var locationFetchRequest: NSFetchRequest<Location>?
    var runFetchRequest: NSFetchRequest<Run>?
    
    var asyncLocFetchRequest: NSAsynchronousFetchRequest<Location>?
    var asyncRunFetchRequest: NSAsynchronousFetchRequest<Run>?
    
    // The array of core data manged objects you'll use to populate the table view.
    var locations: [Location] = []
    var runs: [Run] = []
    
    var lastRun: Run?
    
    // NSPredicates
//    lazy var lastRunPredicate: NSPredicate = {
//        return NSPredicate(format: "%K == %K", #keyPath(Run.date), #keyPath(Run.date))
//    }()
    
    // NSSortDescriptor
    lazy var dateSortDescriptor: NSSortDescriptor = {
        return NSSortDescriptor(key: #keyPath(Run.date), ascending: true)
    }()
    
    // MARK: - View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Core Data
        let app = UIApplication.shared
        let appDelegate = app.delegate as! AppDelegate
        self.context = appDelegate.context
        
        // NSAsynchronousFetchRequest: Performing fetches in the background
        let locFetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
        self.locationFetchRequest = locFetchRequest
        let runFetchRequest: NSFetchRequest<Run> = Run.fetchRequest()
        self.runFetchRequest = runFetchRequest
        
        self.asyncLocFetchRequest = NSAsynchronousFetchRequest(fetchRequest: locFetchRequest, completionBlock: {[unowned self] (result: NSAsynchronousFetchResult) in
            
            guard let locs = result.finalResult else { return }
            self.locations = locs
        })
        
        self.asyncRunFetchRequest = NSAsynchronousFetchRequest(fetchRequest: runFetchRequest, completionBlock: {[unowned self] (result: NSAsynchronousFetchResult) in
            
            guard let runs = result.finalResult else { return }
            self.runs = runs
        })
        
        do {
            guard let asynLocFetchRequest = self.asyncLocFetchRequest,
                  let asynRunFetchRequest = self.asyncRunFetchRequest else { return }
            
            try context.execute(asynLocFetchRequest)
            try context.execute(asynRunFetchRequest)
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        // Core Location
        checkLocationServices()
        
        // Map View
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        print("User Location: \(mapView.userLocation.coordinate)")
        print("User Location Updating: \(mapView.userLocation.isUpdating)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupMapView()
    }
    
    // MARK: - Internal Methods
    // Core Data Methods
    func fetchLastRun() {
        
        guard let runFetch = self.runFetchRequest else { return }
        runFetch.sortDescriptors = [self.dateSortDescriptor]
        
        do {
            
            let runs = try context.fetch(runFetch)
            self.lastRun = runs.last
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    // Map View Methods
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
        fetchLastRun()
        guard let lastRun = self.lastRun else { return nil }
        
        lastRunDateLbl.text = lastRun.date?.formatDateToString()
        lastRunPaceLbl.text = Int(lastRun.avePace).formatTimeDurationToString()
        lastRunSpeedLbl.text = lastRun.aveSpeed.metersToKmForString(places: 2)
        lastRunDurationLbl.text = Int(lastRun.duration).formatTimeDurationToString()
        lastRunDistanceLbl.text = lastRun.distance.metersToKmForString(places: 2)
        
        var coordinates = [CLLocationCoordinate2D]()
        
        if let locs = lastRun.locations {
            
            for location in locs {
                let loc = location as! Location
                coordinates.append(CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude))
            }
            
            mapView.userTrackingMode = .none
            mapView.setRegion(centerMapOnPrevRoute(locations: locs), animated: true)
        }
        
        return MKPolyline(coordinates: &coordinates, count: 0)
    }
    
    func centerMapOnUserLocation() {
        
        mapView.userTrackingMode = .follow
        let coordinateRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func centerMapOnPrevRoute(locations: NSOrderedSet) -> MKCoordinateRegion {
        // First location element is the most current location in NSOrderedSet.
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
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(overlay: polyline)
        renderer.strokeColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        renderer.lineWidth = 3
        return renderer
    }
}

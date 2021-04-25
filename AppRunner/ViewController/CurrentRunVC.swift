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

    // MARK: - Constants - Timer Notification
    let TIMER_IS_ON_UPDATED = Notification.Name("timerIsOnUpdated")
    let START_TIME_UPDATED = Notification.Name("startTimeUpdated")
    let TOTAL_TIME_UPDATED = Notification.Name("totalTimeUpdated")
  
    // MARK: - Variables and Propeties - Core Data
    var coreDataStack: AppDelegate!
    var context: NSManagedObjectContext!
    
    var locFetchRequest: NSFetchRequest<Location>?
    var runFetchRequest: NSFetchRequest<Run>?
    
    var asyncLocFetchRequest: NSAsynchronousFetchRequest<Location>?
    var asyncRunFetchRequest: NSAsynchronousFetchRequest<Run>?
    
    var runs: [Run] = []
    var locations: [Location] = []
    var locCounter = 0
    
    // MARK: - Variables and Propeties - Timer
    var timer = Timer()
    var counter = 0
    
    var timerIsOn: Bool {
        get {
            return UserDefaults.standard.bool(forKey: #function)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    
    var startTime: Date {
        get {
            if let time = UserDefaults.standard.object(forKey: #function) as? Date {return time}
            return Date()
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    
    var totalTime: Double {
        get {
            return UserDefaults.standard.double(forKey: #function)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    
    // MARK: - Variables and Propeties - Map & Run
    var coordinates = [CLLocationCoordinate2D]()
    var startLocation: CLLocation!
    var lastLocation: CLLocation!
//    var locationCache = [CLLocation]()
//    var locationCache = []
    var runDistance: Double = 0.0
    var runCurrentPace = 0
    var runCurrentSpeed = 0.0
    var runAvePace = 0
    var runAveSpeed = 0.0

    
    // MARK: - Variables and Propeties - Location Log
    var logTimestamp: NSDate?
    var logAccuracy: Double = 0.0
    var logSpeed: Double = 0.0
    var logDirection: Double = 0.0
    var eachDistance: Double = 0.0
    
    
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

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Core Data
        let app = UIApplication.shared
        guard let appDelegate = app.delegate as? AppDelegate else { return }
        
        self.coreDataStack = appDelegate
        self.context = coreDataStack.context
                
        // MARK: - Core Location
        checkLocationServices()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        
        // MARK: - UIPanGesture
        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(endRunSwiped(sender:)))
        sliderImageView.addGestureRecognizer(swipeGesture)
        sliderImageView.isUserInteractionEnabled = true
        swipeGesture.delegate = self as? UIGestureRecognizerDelegate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("$$ View Will Appear")
        
        self.locations = []
        self.locCounter = 0

        restoreTimerStatus()
        startRun()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // MARK: - Internal Methods
    func startRun() {
        // Core Location
        locationManager.startUpdatingLocation()
        
        // Timer
        startTimer()
        
        // UI
        pauseBtn.setImage(UIImage(named: "pauseButton"), for: .normal)
    }
    
    func endRun() {
        locationManager.stopUpdatingLocation()
        stopTImer()
        
        // Core Data
        let run = Run(context: context)
        run.id = UUID().uuidString
        run.date = Date()
        
        run.avePace = Int16(runAvePace)
        run.aveSpeed = runAveSpeed
        run.duration = Int16(counter)
        run.distance = runDistance
        
        for loc in locations {
            run.addToLocations(loc)
        }

        coreDataStack.saveContext()
        
        // Test
    }
    
    func pauseRun() {
        startLocation = nil
        locationManager.stopUpdatingLocation()
        pauseTimer()
        
        pauseBtn.setImage(UIImage(named: "resumeButton"), for: .normal)
    }
    
    // MARK: - Timer Model
    func restoreTimerStatus() {
        
        timerIsOn = false
        timer.invalidate()
        totalTime = 0.0
    }
    
    func startTimer() {
        
        if !timerIsOn {
            
            timerIsOn = true
            
            startTime = Date()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(tickTock), userInfo: nil, repeats: true)
        }
    }
    
    func pauseTimer() {
        
        if timerIsOn {
            timerIsOn = false
            
            timer.invalidate()
            totalTime += Date().timeIntervalSince(startTime)
        }
    }
    
    func stopTImer() {
        
        if timerIsOn {
            timerIsOn = false
            
            timer.invalidate()
            totalTime = 0
        }
    }
        
    @objc func tickTock() {
        
        let displayTime = Date().timeIntervalSince(startTime) + totalTime
        convertTimeInteral(interval: displayTime)
        
        counter += 1
    }
    
    func convertTimeInteral(interval: TimeInterval) {
        
        let absInterval = abs(Int(interval))
        
        let secs = absInterval % 60
        let mins = (absInterval / 60) % 60
        let hrs = (absInterval / 3600)
        
        if hrs == 0 {
            durrationLbl.text = String(format: "%.2d", mins) + ":" + String(format: "%.2d", secs)
        }
        else {
            durrationLbl.text = String(hrs) + ":" + String(format: "%.2d", mins) + ":" + String(format: "%.2d", secs)
        }
        
        durrationLbl.font = UIFont.monospacedDigitSystemFont(ofSize: 40, weight: .bold)
    }
    
    // MARK: - Map Methods
    func addCurrentRunToMap(from lastLocation: CLLocation) -> MKPolyline? {

        self.coordinates.append(lastLocation.coordinate)
        
        mapView.setRegion(centerCurrentRoute(from: lastLocation), animated: true)
        return MKPolyline(coordinates: &coordinates, count: coordinates.count)
    }

    func centerCurrentRoute(from lastLocation: CLLocation) -> MKCoordinateRegion {
        
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
    }
    
    // MARK: - Helper Methods
    func calculateCurrentPace(speed: Double) -> Int{
        if speed > 0 {
            return (3600 / speed).toInt()!
        } else {
            return 0
        }
    }
    
    func calculateAvePace(time second: Int, m: Double) -> String {
        if second > 0 && m > 0.00 {
            runAvePace = ((Double(second) / m) * 1000).toInt()!
        } else {
            runAvePace = 0
        }
        return runAvePace.formatTimeDurationToString()
    }
    
    func calculateAveSpeed(time second: Int, m: Double) -> String {
        if second > 0 && m > 0.00 {
            runAveSpeed = (m / Double(second)) * 3600
        } else {
            runAveSpeed = 0.0
        }
        return runAveSpeed.metersToKmForString(places: 2)
    }
    
    // MARK: - IBActions
    @IBAction func pauseBtnPressed(_ sender: Any) {
        
        if timer.isValid {
            pauseRun()
        } else {
            startRun()
        }
    }

    @objc func endRunSwiped(sender: UIPanGestureRecognizer) {
        
        let leftEnd: CGFloat = 83
        let rightEnd: CGFloat = 133
        
        // sliderView - sliderImageView: UIButton which has the gesture recognizer
        if let sliderView = sender.view {
            
            if sender.state == UIGestureRecognizer.State.began ||
                sender.state == UIGestureRecognizer.State.changed {
                
                let translation = sender.translation(in: self.view)
                
                // If slider view is between the left end and right end:
                if sliderView.center.x >= (swipeBGImageView.center.x - leftEnd) &&
                    sliderView.center.x <= (swipeBGImageView.center.x + rightEnd) {
                    
                    sliderView.center.x = sliderView.center.x + translation.x
                    
                }
                // If slider view is over right end:
                else if sliderView.center.x >= (swipeBGImageView.center.x + rightEnd) {
                    
                    sliderView.center.x = swipeBGImageView.center.x + rightEnd
                    
                    // End Run Code goes here
                    endRun()
                      
                    dismiss(animated: true, completion: nil)
                }
                // If slider view is less than left end point:
                else if sliderView.center.x <= (swipeBGImageView.center.x - leftEnd) {
                    
                    sliderView.center.x = swipeBGImageView.center.x - leftEnd
                }
                
                sender.setTranslation(CGPoint.zero, in: self.view)
            }
            else if sender.state == UIGestureRecognizer.State.ended {
                
                UIView.animate(withDuration: 0.1) {
                    sliderView.center.x = self.swipeBGImageView.center.x - leftEnd
                }
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate Methods
extension CurrentRunVC {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // TODO: - Tracking Location
        self.logTimestamp = locations.last?.timestamp as NSDate? // Time
        self.logAccuracy = locations.last!.horizontalAccuracy // Meters
        self.logSpeed = ((locations.last!.speed * 3600) / 1000).setDecimalPlaces(places: 2) // Meters Per Second
        self.logDirection = locations.last!.course // Degrees and relative to due north
                
        if locations.last?.speed.isLess(than: 0) ?? true {
            
        }
        else {
            
            // Core Data caching
            guard let lastLoc = locations.last else {
                return
            }
            let newLocation = Location(context: context)
            newLocation.latitude = Double(lastLoc.coordinate.latitude)
            newLocation.longitude = Double(lastLoc.coordinate.longitude)
            newLocation.int = Int16(locCounter)
            
            locCounter += 1
            self.locations.append(newLocation)

            // Polyline
            if startLocation == nil {
                startLocation = locations.first
//                print("$$$ start location: \(String(describing: startLocation))")

            }
            else if let location = locations.last {
//                print("$$$ location: \(location)")
                eachDistance = lastLocation.distance(from: location)
                runDistance += lastLocation.distance(from: location)
                                
                // Adding Polyline
                if let polyline = addCurrentRunToMap(from: lastLocation) {
                    
                    if mapView.overlays.count > 0 {
                        mapView.removeOverlays(mapView.overlays)
                    }
                    
                    // this method will call: mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer at MKOverlay protocol by the map view delegate.
                    mapView.addOverlay(polyline)

                }
                else {
                    
                }

                distanceLbl.text = runDistance.metersToKmForString(places: 2)
                distanceLbl.font = UIFont.monospacedDigitSystemFont(ofSize: 40, weight: .bold)
                
                runCurrentSpeed = ((location.speed) * 3600) / 1000
                runCurrentPace = calculateCurrentPace(speed: runCurrentSpeed)
                currentSpeedLbl.text = runCurrentSpeed.setDecimalPlaces(places: 2)
                currentSpeedLbl.font = UIFont.monospacedDigitSystemFont(ofSize: 30, weight: .bold)
                currentPaceLbl.text = runCurrentPace.formatTimeDurationToString()
                currentPaceLbl.font = UIFont.monospacedDigitSystemFont(ofSize: 30, weight: .bold)
                
                avePaceLbl.text = calculateAvePace(time: counter, m: runDistance)
                avePaceLbl.font = UIFont.monospacedDigitSystemFont(ofSize: 30, weight: .bold)
                aveSpeedLbl.text = calculateAveSpeed(time: counter, m: runDistance)
                aveSpeedLbl.font = UIFont.monospacedDigitSystemFont(ofSize: 30, weight: .bold)
            }
            
            // important!! don't miss the first "lastLocation" initializing.
            lastLocation = locations.last
        }
    }
}

// MARK: - MKMapViewDelegate
extension CurrentRunVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(overlay: polyline)
        renderer.strokeColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        renderer.lineWidth = 3
        return renderer
    }

}

// MARK: - Core Data Helper
extension CurrentRunVC {
    
    func asyncRFR() {
        
        // NSAsynchronousFetchRequest: Performing fetches in the background
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
        
        // NSAsynchronousFetchRequest: Performing fetches in the background
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

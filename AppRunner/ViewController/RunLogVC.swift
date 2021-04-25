//
//  RunLogVC.swift
//  AppRunner
//
//  Created by leslie on 1/16/21.
//

import UIKit
import MapKit
import CoreData

// MARK: - LocationVC
class RunLogVC: LocationVC {

    // MARK: - Variables and Propeties - Core Data
    var coreDataStack: AppDelegate!
    var context: NSManagedObjectContext!
    
    var locFetchRequest: NSFetchRequest<Location>?
    var runFetchRequest: NSFetchRequest<Run>?
    
    var asyncLocFetchRequest: NSAsynchronousFetchRequest<Location>?
    var asyncRunFetchRequest: NSAsynchronousFetchRequest<Run>?
    
    var locations: [Location] = []
    var runs: [Run] = []
    var selectedRun: Run?

    /// NSSortDescriptor
    lazy var dateSortDescriptor: NSSortDescriptor = {
        return NSSortDescriptor(key: #keyPath(Run.date), ascending: true)
    }()
    
    lazy var dateReversedSortDescriptor: NSSortDescriptor = {
        return NSSortDescriptor(key: #keyPath(Run.date), ascending: false)
    }()

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Table View
        tableView.delegate = self
        tableView.dataSource = self
        
        // Core Data
        let app = UIApplication.shared
        guard let appDelegate = app.delegate as? AppDelegate else { return }
        
        self.coreDataStack = appDelegate
        self.context = coreDataStack.context
        
        /// Print simulater sotre url.
//        guard let storeURL = context.persistentStoreCoordinator?.persistentStores.first?.url else { return }
//        print("Simulator store url: \(String(describing: storeURL))")
        
        /// NSAsynchronousFetchRequest: Performing fetches in the background
        asyncRFR()
//        asyncLFR()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        asyncRFR()

    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(#function)
        
        guard segue.identifier == "segueToShowRouteVC",
              let showRoutVC = segue.destination as? ShowRouteVC
        else { return }
        
        showRoutVC.selectedRun = selectedRun
        
    }
    
}

// MARK: - Table View Data Source
extension RunLogVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return runs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RunLogCell", for: indexPath) as? RunLogCell else { return UITableViewCell() }
        
        let run = runs[indexPath.row]
        cell.configure(run: run)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        print(#function)
        print(">>> runs: \(self.runs.count)")
        print(">>> index: \(indexPath.row)")
        
        guard editingStyle == .delete else { return }
        let runToRemove = runs[indexPath.row] as Run
        
        self.coreDataStack.context.delete(runToRemove)
        self.coreDataStack.saveContext()
        
        asyncRFR()
        
        tableView.deleteRows(at: [indexPath], with: .automatic)
//        tableView.reloadData()
    }
}

// MARK: - Table View Delegate
extension RunLogVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#function)
        
//        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        self.selectedRun = runs[indexPath.row]
        
        performSegue(withIdentifier: "segueToShowRouteVC", sender: self)
    }
}

// MARK: - Core Data Helper
extension RunLogVC {
    
    func asyncRFR() {
        
        // NSAsynchronousFetchRequest: Performing fetches in the background
        let rfr: NSFetchRequest<Run> = Run.fetchRequest()
        self.runFetchRequest = rfr
        self.runFetchRequest?.sortDescriptors = [self.dateReversedSortDescriptor]

        self.asyncRunFetchRequest = NSAsynchronousFetchRequest(fetchRequest: rfr, completionBlock: {[unowned self] (result: NSAsynchronousFetchResult) in
            
            guard let runs = result.finalResult else { return }
            self.runs = runs
            
            self.tableView.reloadData()
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

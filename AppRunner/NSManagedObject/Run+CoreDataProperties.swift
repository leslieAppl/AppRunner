//
//  Run+CoreDataProperties.swift
//  AppRunner
//
//  Created by leslie on 1/20/21.
//
//

import Foundation
import CoreData


extension Run {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Run> {
        return NSFetchRequest<Run>(entityName: "Run")
    }

    @NSManaged public var id: String?
    @NSManaged public var date: Date?
    @NSManaged public var distance: Double
    @NSManaged public var duration: Int16
    @NSManaged public var avePace: Int16
    @NSManaged public var aveSpeed: Double
    @NSManaged public var locations: NSSet?

}

// MARK: Generated accessors for locations
extension Run {

    @objc(addLocationsObject:)
    @NSManaged public func addToLocations(_ value: Location)

    @objc(removeLocationsObject:)
    @NSManaged public func removeFromLocations(_ value: Location)

    @objc(addLocations:)
    @NSManaged public func addToLocations(_ values: NSSet)

    @objc(removeLocations:)
    @NSManaged public func removeFromLocations(_ values: NSSet)

}

extension Run : Identifiable {

}

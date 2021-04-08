//
//  Location+CoreDataProperties.swift
//  AppRunner
//
//  Created by leslie on 4/8/21.
//
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var run: Run?

}

extension Location : Identifiable {

}

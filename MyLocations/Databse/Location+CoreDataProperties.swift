//
//  Location+CoreDataProperties.swift
//  MyLocations
//
//  Created by Micah on 2/26/22.
//
//

import Foundation
import CoreData
import CoreLocation


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var date: Date
    @NSManaged public var locationDescription: String
    @NSManaged public var category: String
    @NSManaged public var placemark: CLPlacemark?
    @NSManaged public var photoID: NSNumber?
    
    func removePhotoFile() {
        if hasPhoto {
            do { try FileManager.default.removeItem(at: photoURL) }
            catch { print("Error removing file: \(error)") }
        }
    }
}

extension Location : Identifiable {

}

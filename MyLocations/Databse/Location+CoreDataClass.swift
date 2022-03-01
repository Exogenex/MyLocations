//
//  Location+CoreDataClass.swift
//  MyLocations
//
//  Created by Micah on 2/26/22.
//
//

import Foundation
import CoreData
import MapKit

@objc(Location)
public class Location: NSManagedObject, MKAnnotation {
    public var coordinate: CLLocationCoordinate2D { return CLLocationCoordinate2DMake(latitude, longitude) }
    
    public var title: String? {
        if locationDescription.isEmpty { return "(No Description)" }
        else { return locationDescription }
    }
    
    public var subtitle: String? { return category }
    
    var hasPhoto: Bool { return photoID != nil }
    var photoURL: URL {
        assert(photoID != nil, "No photo ID set")
        let filename = "Photo-\(photoID!.intValue).jpg"
        return applicationDocumentsDirectory.appendingPathComponent(filename)
    }
    var photoImage: UIImage? { return UIImage(contentsOfFile: photoURL.path) }
    
    class func nextPhotoID() -> Int {
        let userDefaults = UserDefaults.standard
        let currentID = userDefaults.integer(forKey: "PhotoID") + 1
        userDefaults.set(currentID, forKey: "PhotoID")
        return currentID
    }
}

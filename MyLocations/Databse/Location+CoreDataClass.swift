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
}

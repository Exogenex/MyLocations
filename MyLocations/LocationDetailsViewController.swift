//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Micah on 2/24/22.
//

import UIKit
import CoreLocation

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

class LocationDetailsViewController: UITableViewController {
    
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    
    var categoryName = "No Category"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTextView.text = ""
        categoryLabel.text = categoryName
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placemark { addressLabel.text = string(from: placemark) }
        else { addressLabel.text = "No Address Found" }
        
        dateLabel.text = format(date: Date())
    }
    
    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {
        let controller = segue.source as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
    
    // MARK: - Actions
    @IBAction func done() { navigationController?.popViewController(animated: true) }
    
    @IBAction func cancel() { navigationController?.popViewController(animated: true) }
    
    // MARK: - Helper Methods
    func string(from placemark: CLPlacemark) -> String {
        var text = ""
        
        if let tmp = placemark.subThoroughfare {text += tmp + " "}
        if let tmp = placemark.thoroughfare {text += tmp + ", "}
        if let tmp = placemark.locality {text += tmp + ", "}
        if let tmp = placemark.administrativeArea {text += tmp + " "}
        if let tmp = placemark.postalCode {text += tmp + ", "}
        if let tmp = placemark.country {text += tmp}
        
        return text
    }
    
    func format(date: Date) -> String { return dateFormatter.string(from: date) }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
}

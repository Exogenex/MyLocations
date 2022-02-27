//
//  ViewController.swift
//  MyLocations
//
//  Created by Micah on 2/22/22.
//

import UIKit
import CoreLocation
import CoreData

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {

    //outlets for labels
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    let locationManager = CLLocationManager()
    
    var location: CLLocation?
    var updatingLocation = false
    var lastLocationError: Error?
    
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: Error?
    
    var timer: Timer?
    
    var managedObjectContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
    }
    
    //show/hide navigation bar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Navigation
    //segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TagLocation" {
            let controller = segue.destination as! LocationDetailsViewController
            controller.coordinate = location!.coordinate
            controller.placemark = placemark
            controller.managedObjectContext = managedObjectContext
        }
    }
    
    // MARK: - Actions
    //get location button action
    @IBAction func getLocation() {
        let authStatus = locationManager.authorizationStatus
        if authStatus == .notDetermined { locationManager.requestWhenInUseAuthorization(); return }
        
        if authStatus == .denied || authStatus == .restricted { showLocationServicesDeniedAlert(); return }
        
        if updatingLocation { stopLocationManager() }
        else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        
        updateLabels()
    }
    
    // MARK: - CLLocationManagerDelegate
    //error handling
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error.localizedDescription)")
        
        if (error as NSError).code == CLError.locationUnknown.rawValue{ return }
        
        lastLocationError = error
        stopLocationManager()
        updateLabels()
    }
    
    //get the location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 { return }
        if newLocation.horizontalAccuracy < 0 { return }
        
        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        if let location = location { distance = newLocation.distance(from: location) }
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            lastLocationError = nil
            location = newLocation
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("*** We're done!")
                stopLocationManager()
                if distance > 0 { performingReverseGeocoding = false }
            }
            updateLabels()
            
            if !performingReverseGeocoding {
                print("*** Going to geocode")
                
                performingReverseGeocoding = true
                
                geocoder.reverseGeocodeLocation(newLocation) {placemarks, error in
                    self.lastGeocodingError = error
                    
                    if error == nil, let places = placemarks, !places.isEmpty { self.placemark = places.last! }
                    else { self.placemark = nil }
                    
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                }
            } else if distance < 1 {
                let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
                if timeInterval > 10 {
                    print("*** Force done!")
                    stopLocationManager()
                    updateLabels()
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    //loction settings disabled in phone
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    //update the labels to hold the location data
    func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = ""
            
            if let placemark = placemark { addressLabel.text = string(from: placemark) }
            else if performingReverseGeocoding { addressLabel.text = "Searching for Address..." }
            else if lastGeocodingError != nil { addressLabel.text = "Error Finding Address" }
            else { addressLabel.text = "No Address Found" }
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            let statusMessage: String
            if let error = lastLocationError as NSError? {
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue { statusMessage = "Location Services Disabled" }
                else { statusMessage = "Error Getting Location" }
            }
            else if !CLLocationManager.locationServicesEnabled() { statusMessage = "Location Services Disabled" }
            else if updatingLocation { statusMessage = "Searching..." }
            else { statusMessage = "Tap 'Get My Location' to Start" }
            messageLabel.text = statusMessage
        }
        configureGetButton()
    }
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            
            timer = Timer.scheduledTimer(
                timeInterval: 60,
                target: self,
                selector: #selector(didTimeOut),
                userInfo: nil,
                repeats: false)
        }
    }
    
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            
            if let timer = timer { timer.invalidate() }
        }
    }
    
    func configureGetButton() {
        if updatingLocation { getButton.setTitle("Stop", for: .normal) }
        else { getButton.setTitle("Get My Location", for: .normal) }
    }
    
    func string(from placemark: CLPlacemark) -> String {
        var line1 = ""
        if let tmp = placemark.subThoroughfare { line1 += tmp + " " }
        if let tmp = placemark.thoroughfare { line1 += tmp }
        
        var line2 = ""
        if let tmp = placemark.locality { line2 += tmp + " " }
        if let tmp = placemark.administrativeArea { line2 += tmp + " " }
        if let tmp = placemark.postalCode { line2 += tmp }
        
        return line1 + "\n" + line2
    }
    
    @objc func didTimeOut() {
        print("*** Time out")
        
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(
                domain: "MyLocationsErrorDomain",
                code: 1,
                userInfo: nil)
            
            updateLabels()
        }
    }

}


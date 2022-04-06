//
//  LocationManager.swift
//  WeatherApp
//
//  Created by Dmytro Maksymyak on 17.03.2022.
//

import CoreLocation
import MapKit

class LocationManager {
    private static var locationSet: ((MKMapItem) -> Void)?
    private static var locationManagerDelegate = LocationManagerDelegate(locatedAction: locationChanged(currentLocation:))
    
    public static var isEnabled: Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch shared.authorizationStatus {
            case .notDetermined, .restricted, .denied:
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            default: return false
            }
        }
        return false
    }

    static let shared: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        
        locationManager.delegate = locationManagerDelegate
        locationManager.startMonitoringSignificantLocationChanges()
        
        return locationManager
    }()
    
    private static func locationChanged(currentLocation: MKMapItem) {
        locationSet?(currentLocation)
        print("Location changed \(currentLocation)")
    }
    
    public static func setNewLocationCompletion(locationChanged: @escaping (MKMapItem) -> Void) {
        locationSet = locationChanged
    }
    
    private init() {}
}

class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    var isLoaded = false
    init(locatedAction: @escaping (MKMapItem) -> Void) {
        self.locatedAction = locatedAction
    }
    var locatedAction: ((MKMapItem) -> Void)?
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !isLoaded {
            let currentLocation = MKMapItem(placemark: MKPlacemark(coordinate: locations.last!.coordinate))
            currentLocation.name = "Current Location"
            isLoaded = true
            locatedAction?(currentLocation)
            print("Updated current location: ", currentLocation.placemark.coordinate)
            manager.stopUpdatingLocation()
        }
    }
}

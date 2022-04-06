//
//  CurrentLocationHelper.swift
//  WeatherApp
//
//  Created by Dmytro Maksymyak on 17.03.2022.
//

import Foundation
import CoreLocation
import MapKit

class CurrentLocationHelper: NSObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager!
    private var currentLocation = CLLocation()
    
    
    override init() {
        super.init()
        
        
        
        if CLLocationManager.locationServicesEnabled() {
//            locationManager.startUpdatingLocation()
            print("enalbed")
        } else {
            print("disabled")
        }
    }
    
    public func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    public func getManager() -> CLLocationManager {
        return locationManager
    }
    
    public func getCurrentLocation() -> MKMapItem{
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: currentLocation.coordinate))
        return mapItem
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last!
        for location in locations {
            print(location.coordinate)
        }
    }
}

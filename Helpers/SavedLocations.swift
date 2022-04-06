//
//  SavedLocations.swift
//  WeatherApp
//
//  Created by Dmytro Maksymyak on 05.03.2022.
//

import Foundation
import MapKit
import Combine

class SavedLocations {
    static var shared: SavedLocations = {
        return SavedLocations()
    }()
    init() {
        loadSavedLocations()
        LocationManager.setNewLocationCompletion(locationChanged: gotCurrentLocation(currentLocation:))
    }
    
    public func setLocationChangeAction(locationChangedAction: @escaping ([MKMapItem]) -> Void) {
        locationChangeAction = locationChangedAction
    }
    
    private var locationChangeAction: (([MKMapItem]) -> Void)?
    private var isLoaded = false
    
    private var savedLocations: [MKMapItem] = [] {
        didSet {
            if savedLocations != oldValue {
                locationsChanged()
            }
        }
    }
    private var currentLocation: MKMapItem? {
        didSet {
            locationsChanged()
        }
    }
    
    public func loadSavedLocations() {
        print("Loading saved locations")
        do {
            if let loadedLocations = UserDefaults.standard.data(forKey: "savedLocations"),
               let decodedLocations = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(loadedLocations) as? [MKMapItem] {
                savedLocations = decodedLocations
                isLoaded = true
                print("Loaded saved locations")
            }
        } catch {
            print("Error loading locatinos")
        }
    }
    
    private func gotCurrentLocation(currentLocation: MKMapItem) {
        self.currentLocation = currentLocation
    }
    
    private func locationsChanged() {
        var tempLocations: [MKMapItem] = []
        if let currentLocation = currentLocation {
            tempLocations.append(currentLocation)
        }
        tempLocations.append(contentsOf: savedLocations)
        print("Location list has changed")
        locationChangeAction?(tempLocations)
    }
    
    public func addLocation(_ location: MKMapItem) {
        savedLocations.append(location)
        saveLocations()
    }
    
    public func addLocation(_ location: MKMapItem,to position: Int) {
        savedLocations.insert(location, at: position)
        saveLocations()
    }
    
    private func saveLocations() {
        if let encodedLocations = try? NSKeyedArchiver.archivedData(withRootObject: savedLocations, requiringSecureCoding: false) {
            UserDefaults.standard.set(encodedLocations, forKey: "savedLocations")
        }
    }
    
    public func deleteLocation(atRow row: Int) {
        savedLocations.remove(at: row)
        saveLocations()
    }
    
    
    public func getLocations() -> [MKMapItem] {
        if isLoaded {
            return savedLocations
        } else {
            loadSavedLocations()
            return savedLocations
        }
    }
}

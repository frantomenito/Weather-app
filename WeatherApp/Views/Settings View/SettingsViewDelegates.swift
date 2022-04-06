//
//  SettingsViewDelegates.swift
//  WeatherApp
//
//  Created by Dmytro Maksymyak on 05.04.2022.
//

import Foundation
import MapKit
import UIKit
//MARK: SearchTableViewDataSourceAndDelegate
class SearchTableViewDataSourceAndDelegate: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    private var searchResult: [MKLocalSearchCompletion] = []
    private var searchBar: UISearchBar!
    public func setSearchResults(_ searchResult: [MKLocalSearchCompletion]) {
        self.searchResult = searchResult
    }
    public func setSearchBar(_ searchBar: UISearchBar) {
        self.searchBar = searchBar
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = searchResult[indexPath.row]
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        
        var content = cell.defaultContentConfiguration()
        
        content.text = searchResult.title
        content.secondaryText = searchResult.subtitle
        content.textProperties.color = .white
        content.secondaryTextProperties.color = .white
        
        cell.backgroundColor = tableView.backgroundColor
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let result = searchResult[indexPath.row]
        let searchRequest = MKLocalSearch.Request(completion: result)
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            guard let item = response?.mapItems[0] else {
                return
            }
            SavedLocations.shared.addLocation(item)
            self.searchBar.endEditing(true)
        }
    }
}

//MARK: SavedLocationsTableViewDataSourceAndDelegate
class SavedLocationsTableViewDataSourceAndDelegate: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SavedLocations.shared.getLocations().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        
        var content = cell.defaultContentConfiguration()
        
        content.text = SavedLocations.shared.getLocations()[indexPath.row].name
        content.textProperties.color = .white
        
        cell.backgroundColor = tableView.backgroundColor
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            SavedLocations.shared.deleteLocation(atRow: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movingItem = SavedLocations.shared.getLocations()[sourceIndexPath.row]
        SavedLocations.shared.deleteLocation(atRow: sourceIndexPath.row)
        SavedLocations.shared.addLocation(movingItem, to: destinationIndexPath.row)
    }
}

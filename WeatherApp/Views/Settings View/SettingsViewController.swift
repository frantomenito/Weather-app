//
//  SettingsViewController.swift
//  WeatherApp
//
//  Created by Dmytro Maksymyak on 19.02.2022.
//

import UIKit
import MapKit

class SettingsViewController: UIViewController, MKLocalSearchCompleterDelegate, UISearchBarDelegate {

    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var unitsButton: UIButton!
    @IBOutlet weak var editButtonConstraint: NSLayoutConstraint!
    
    private var searchCompleter = MKLocalSearchCompleter()
    private var searchResult: [MKLocalSearchCompletion] = []
    private var searchTableViewDataSourceAndDelegate = SearchTableViewDataSourceAndDelegate()
    private var savedLocationsTableViewDataSourceAndDelegate = SavedLocationsTableViewDataSourceAndDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configure()
    }
    
    private func configure() {
        searchBar.searchTextField.textColor = .white
        unitsButton.setImage(ConversionHelper.shared.getCurrentUnits() == .Fahrenheit ? UIImage(named: "fahrenheit") : UIImage(named: "celsius"), for: .normal)
        
        searchCompleter.region = MKCoordinateRegion(.world)
        searchCompleter.resultTypes = MKLocalSearchCompleter.ResultType([.address])
        
        searchCompleter.delegate = self
        searchBar.delegate = self
        searchTableViewDataSourceAndDelegate.setSearchResults(searchResult)
        searchTableViewDataSourceAndDelegate.setSearchBar(searchBar)
        searchResultsTableView.delegate = searchTableViewDataSourceAndDelegate
        searchResultsTableView.dataSource = searchTableViewDataSourceAndDelegate
        
        tableView.delegate = savedLocationsTableViewDataSourceAndDelegate
        tableView.dataSource = savedLocationsTableViewDataSourceAndDelegate
    }
    
    //MARK: IBActions
    @IBAction func unitsButtonPressed(_ sender: Any) {
        if unitsButton.currentImage == UIImage(named: "fahrenheit") {
            unitsButton.setImage(UIImage(named: "celsius"), for: .normal)
            ConversionHelper.shared.setUnitsTo(.Celsius)
        } else {
            unitsButton.setImage(UIImage(named: "fahrenheit"), for: .normal)
            ConversionHelper.shared.setUnitsTo(.Fahrenheit)
        }
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        editButton.setTitle(editButton.titleLabel?.text == NSLocalizedString("Edit", comment: "") ? NSLocalizedString("Done", comment: "") : NSLocalizedString("Edit", comment: ""), for: .normal)
    }
    
    //MARK: Searchbar delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text != "" {
            searchResultsTableView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        } else {
            searchTableViewDataSourceAndDelegate.setSearchResults([])
            searchResultsTableView.reloadData()
            searchResultsTableView.backgroundColor = UIColor(red: 5/265, green: 5/265, blue: 5/265, alpha: 0.69)
        }
        searchCompleter.queryFragment = searchText
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResult = completer.results
        searchTableViewDataSourceAndDelegate.setSearchResults(searchResult)
        searchResultsTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchResultsTableView.isHidden = false
        searchResultsTableView.isUserInteractionEnabled = true
        tableView.isUserInteractionEnabled = false
        searchBar.setShowsCancelButton(true, animated: true)
        toggleTopButtons()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchResultsTableView.reloadData()
        searchResultsTableView.isHidden = true
        searchResultsTableView.isUserInteractionEnabled = false
        tableView.isUserInteractionEnabled = true
        tableView.reloadData()
        toggleTopButtons()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.text = ""
    }
    
    //MARK: Helper functions
    
    private func toggleTopButtons() {
        editButtonConstraint.constant = editButtonConstraint.constant == -45 ? 16 : -45
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}


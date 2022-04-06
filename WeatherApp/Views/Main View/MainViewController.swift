//
//  ViewController.swift
//  WeatherApp
//
//  Created by Dmytro Maksymyak on 18.06.2021.
//

import UIKit
import MapKit

class MainViewController: UIViewController {
    
    //MARK: Variables
    private var locations = SavedLocations.shared.getLocations() {
        didSet {
            if locations != oldValue {
                print("New locations")
            }
        }
    }
    private var currentWeather = [CurrentWeather?]()
    private var backgroundLayer: CAGradientLayer! = ColorHelper.shared.getGradient()
    
    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        SavedLocations.shared.setLocationChangeAction(locationChangedAction: locationChangedAction(newLocations:))
        if locations.isEmpty {
            view = NoLocationsView(pressAction: pressAction)
            view.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        } else {
            view = MainView(locations: locations, pressAction: pressAction, scrolledAction: paintTheBackground(basedOn:), currentWeather: currentWeatherGotLoaded(currentWeather:))
            prepareBackground()
        }
    }
    
    //MARK: Button pressed function
    private func pressAction() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyBoard.instantiateViewController(withIdentifier: "settingsVC")
        
        secondVC.modalPresentationStyle = .popover
        secondVC.modalTransitionStyle = .coverVertical
        
        present(secondVC, animated: true, completion: nil)
    }
    
    //MARK: Helper functions
    private func locationChangedAction(newLocations: [MKMapItem]) {
        locations = newLocations
        self.loadView()
    }
    
    //MARK: Painting background
    private func prepareBackground() {
        view.backgroundColor = .clear
        backgroundLayer.frame = view.frame
        print(view.frame)
        view.layer.insertSublayer(backgroundLayer, at: 0)
    }
    
    private func currentWeatherGotLoaded(currentWeather: [CurrentWeather]) {
        self.currentWeather = currentWeather
        paintTheBackground(basedOn: 0)
    }
    
    private func paintTheBackground(basedOn page: Int) {
        if currentWeather.count - 1 >= page {
            guard let weather = currentWeather[page] else { return }
            ColorHelper.shared.animateGradient(backgroundLayer, basedOn: weather)
        }
    }
}

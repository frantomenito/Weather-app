//
//  WeatherInfoView.swift
//  WeatherApp
//
//  Created by Dmytro Maksymyak on 07.03.2022.
//

import Foundation
import UIKit
import MapKit

class WeatherInfoView: UIView {
    private var firstCancellable: Any? = nil
    private var secondCancellable: Any? = nil

    lazy var groupView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width - 50, height: self.frame.height/3))
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view.backgroundColor = ColorHelper.shared.getBackgroundColor()
        firstCancellable = colorPublisher.sink{ color in UIView.animate(withDuration: 0.5) { view.backgroundColor = color }}

        return view
    }()
    
    //MARK: Labels
    lazy var cityLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "London"
        label.font = .systemFont(ofSize: 30)
        label.textColor = .white
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 0.15
        label.layer.shadowOpacity = 0.1
        label.layer.shadowOffset = CGSize(width: 2, height: 2)
        label.layer.masksToBounds = false

        return label
    }()
    
    lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 90)
        label.text = " 69°"
        label.textColor = .white
        label.layer.shadowColor = cityLabel.layer.shadowColor
        label.layer.shadowRadius = cityLabel.layer.shadowRadius
        label.layer.shadowOpacity = cityLabel.layer.shadowOpacity
        label.layer.shadowOffset = cityLabel.layer.shadowOffset
        label.layer.masksToBounds = cityLabel.layer.masksToBounds
        
        secondCancellable = temperaturePublisher.sink { [self] _ in
            label.text = " \(convertor.tempOnCurrentUnits(currentTemperature))" + "°"
        }
        
        return label
    }()
    
    lazy var summaryLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20)
        label.text = NSLocalizedString("Sunny", comment: "")
        label.textColor = .white
        label.layer.shadowColor = cityLabel.layer.shadowColor
        label.layer.shadowRadius = cityLabel.layer.shadowRadius + 0.1
        label.layer.shadowOpacity = cityLabel.layer.shadowOpacity
        label.layer.shadowOffset = cityLabel.layer.shadowOffset
        label.layer.masksToBounds = cityLabel.layer.masksToBounds
        
        return label
    }()
    
    //MARK: CollectionViews
    lazy var dailyCollectionView: UICollectionView = {
        let scrollLayout = UICollectionViewFlowLayout()
        scrollLayout.scrollDirection = .horizontal
        scrollLayout.itemSize = CGSize(width: groupView.frame.width/6, height: groupView.frame.height/2.5)
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: groupView.frame.width, height: groupView.frame.height), collectionViewLayout: scrollLayout)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: "dailyCell")
        
        collectionView.layer.masksToBounds = true
        collectionView.clipsToBounds = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = false
        collectionView.backgroundColor = .clear
        
        return collectionView
    }()
    
    //TODO: create line to separate collection views
    
    lazy var hourlyCollectionView: UICollectionView = {
        let scrollLayout = UICollectionViewFlowLayout()
        scrollLayout.scrollDirection = .horizontal
        scrollLayout.itemSize = CGSize(width: groupView.frame.width/6, height: groupView.frame.height/2.5)
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: groupView.frame.width, height: groupView.frame.height), collectionViewLayout: scrollLayout)

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: "hourlyCell")
        
        collectionView.clipsToBounds = true
        collectionView.layer.masksToBounds = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = false
        collectionView.backgroundColor = .clear
        
        return collectionView
    }()
    
    //TODO: This views replace with separate custom views to decrease this view size
    
    var hourlyCollectionViewViewDelegateAndDataSource = self
    var dailyCollectionViewDelegateAndDataSource = self
    let colorPublisher = ColorHelper.shared.passthroughtSubject
    let temperaturePublisher = ConversionHelper.shared.passthroughtSubject
    
    //MARK: Inits

    init(frame: CGRect, location: MKMapItem,_ completion: @escaping (CurrentWeather) -> Void) {
        super.init(frame: frame)
        loadData(location: location, { [self] in
            createConstraints()
            completion(getCurrentWeather())
        })
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    private var currentTemperature = 0.0
    private var dailyWeather = [DailyWeatherData]()
    private var hourlyWeather = [HourlyWeatherData]()
    private var currentWeather: CurrentWeather!
    private var timeZone = ""
    
    private let convertor = ConversionHelper.shared
    
    
    //MARK: Constraints
    private func createConstraints() {
        addSubview(groupView)
        addSubview(summaryLabel)
        addSubview(temperatureLabel)
        addSubview(cityLabel)
        groupView.addSubview(hourlyCollectionView)
        groupView.addSubview(dailyCollectionView)
        
        hourlyCollectionView.contentSize = CGSize(width: hourlyCollectionView.contentSize.width + 10000, height: hourlyCollectionView.contentSize.height)
        dailyCollectionView.contentSize = CGSize(width: dailyCollectionView.contentSize.width + 10000, height: dailyCollectionView.contentSize.height)
        
        groupView.translatesAutoresizingMaskIntoConstraints = false
        hourlyCollectionView.translatesAutoresizingMaskIntoConstraints = false
        dailyCollectionView.translatesAutoresizingMaskIntoConstraints = false
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        cityLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            groupView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
            ,groupView.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 20)
            ,groupView.heightAnchor.constraint(equalToConstant: self.frame.height/3)
            ,groupView.widthAnchor.constraint(equalToConstant: self.frame.width - 25)
            
            ,hourlyCollectionView.topAnchor.constraint(equalTo: groupView.topAnchor, constant: groupView.frame.height/12)
            ,hourlyCollectionView.widthAnchor.constraint(equalTo: groupView.widthAnchor)
            ,hourlyCollectionView.centerXAnchor.constraint(equalTo: groupView.centerXAnchor)
            ,hourlyCollectionView.heightAnchor.constraint(equalToConstant: groupView.bounds.height / 2.5)
            ,dailyCollectionView.bottomAnchor.constraint(equalTo: groupView.bottomAnchor, constant: -groupView.frame.height/12)
            ,dailyCollectionView.widthAnchor.constraint(equalTo: groupView.widthAnchor)
            ,dailyCollectionView.centerXAnchor.constraint(equalTo: groupView.centerXAnchor)
            ,dailyCollectionView.heightAnchor.constraint(equalTo: hourlyCollectionView.heightAnchor)
        
            ,summaryLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
            ,summaryLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 5)
        
            ,temperatureLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
            ,temperatureLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: self.bounds.maxY/5)
            
            ,cityLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
            ,cityLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 10)
        ])
    }    
    
    //MARK: Helper funcs
    private func getCurrentWeather() -> CurrentWeather {
        return currentWeather
    }
    
    private func paintTheGroupView(_ color: UIColor) {
        UIView.animate(withDuration: 0.5) { [self] in
            groupView.backgroundColor = color
        }
    }
    private func loadData(location: MKMapItem, _ completion: @escaping () -> Void) {
        WeatherManagerHelper().loadData(location: location) { [self] dailyWeather, hourlyWeather, currentWeather, timeZone in
            DispatchQueue.main.async {
                currentTemperature = currentWeather.temperature
                temperatureLabel.text = " \(convertor.tempOnCurrentUnits(currentTemperature))" + "°"
                summaryLabel.text = NSLocalizedString(currentWeather.summary, value: currentWeather.summary, comment: "")
                self.currentWeather = currentWeather
                self.hourlyWeather = hourlyWeather
                self.dailyWeather = dailyWeather
                self.timeZone = timeZone
                cityLabel.text = NSLocalizedString(location.name!, value: location.name!, comment: "")
                hourlyCollectionView.reloadData()
                dailyCollectionView.reloadData()
                completion()
            }
        }
    }
}

//MARK: CollectionView's delegates

extension WeatherInfoView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.height, height: collectionView.bounds.height)
    }
 
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: CustomCollectionViewCell!
        
        if collectionView == hourlyCollectionView {
            let savedDate = Date(timeIntervalSince1970: TimeInterval(currentWeather.time))
            let components = Calendar.current.dateComponents([.hour], from: savedDate, to: Date())
            let hourDifference = components.hour ?? 0
            
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hourlyCell", for: indexPath) as! CustomCollectionViewCell
            
            if !hourlyWeather.isEmpty {cell.setHourlyData(with: hourlyWeather[indexPath.row + hourDifference], indexPath.row == 0 ? true : false, timeZone)}
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dailyCell", for: indexPath) as! CustomCollectionViewCell
            
            if !dailyWeather.isEmpty {cell.setDailyData(with: dailyWeather[indexPath.row], indexPath.row)}
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == dailyCollectionView {
            return 7
        } else {
            return 24
        }
    }
}

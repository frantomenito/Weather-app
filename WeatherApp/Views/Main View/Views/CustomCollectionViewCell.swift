//
//  CustomCollectionViewCell.swift
//  WeatherApp
//
//  Created by Dmytro Maksymyak on 06.07.2021.
//

import UIKit
import Combine

class CustomCollectionViewCell: UICollectionViewCell {
    private var cancellable: Any? = nil

    private var imageView: UIImageView =  {
        let imageView = UIImageView()
        
        imageView.image = UIImage(named: "rain")
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowRadius = 0.15
        imageView.layer.shadowOpacity = 0.1
        imageView.layer.shadowOffset = CGSize(width: 2, height: 2)
        imageView.layer.masksToBounds = false
        
        return imageView
    }()
    private var titleLabel: UILabel = {
        let label = UILabel()
        
        label.text = NSLocalizedString("Now", comment: "")
        label.textColor = .white
        label.textAlignment = .center
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 0.15
        label.layer.shadowOpacity = 0.1
        label.layer.shadowOffset = CGSize(width: 2, height: 2)
        label.layer.masksToBounds = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        label.numberOfLines = 1
        
        return label
    }()
    
    private let publisher = ConversionHelper.shared.passthroughtSubject
    private var temperatureLabel: UILabel = {
        let label = UILabel()
        
        label.text = "69"
        label.textColor = .white
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 0.15
        label.layer.shadowOpacity = 0.1
        label.layer.shadowOffset = CGSize(width: 2, height: 2)
        label.layer.masksToBounds = false
        label.font = UIFont.boldSystemFont(ofSize: 20)
                
        return label
    }()
         
    private let convertor = ConversionHelper.shared

    private var currentTemperature = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        cancellable = publisher.sink {_ in self.refreshValues() }
        
        createConstraints()
        self.layer.borderWidth = 0
        self.layer.borderColor = UIColor.clear.cgColor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //MARK: Constrains
    func createConstraints() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(temperatureLabel)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: contentView.bounds.height / 2),
            imageView.widthAnchor.constraint(equalToConstant: contentView.bounds.height / 2),
            
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: imageView.topAnchor),

            temperatureLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            temperatureLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    //MARK: Getting data functions
    func setDailyData(with weather: DailyWeatherData, _ indexPathRow: Int) {
        if indexPathRow == 0 {
            if Locale.preferredLanguages.first == "uk-UA" {
                
            }
            titleLabel.text = NSLocalizedString("Today", comment: "")
        } else {
            titleLabel.text = getDate(from: Date(timeIntervalSince1970: Double(weather.time)), dateFormat: .daily, nil) //Day of week
        }
        
        currentTemperature = Int(weather.temperatureMax)
        temperatureLabel.text = " \(convertor.tempOnCurrentUnits(Double(currentTemperature)))" + "°" //Temperature
        
        switch weather.icon { //Changing icon based on weather
        case "rain":
            imageView.image = UIImage(named: "rainyDay")
        case "snow", "sleet":
            imageView.image = UIImage(named: "snowyDay")
        case "cloudy", "partly-cloudy-day", "partly-cloudy-night":
            imageView.image = UIImage(named: "cloudyDay")
        default:
            imageView.image = UIImage(named: "Day")
        }
        
        
    }
    
    func setHourlyData(with weather: HourlyWeatherData, _ isFirst: Bool, _ timeZone: String) {
        let hour = getDate(from: Date(timeIntervalSince1970: Double(weather.time)), dateFormat: .hourly, timeZone) //Hour
        
        if isFirst {
            titleLabel.text = NSLocalizedString("Now", comment: "")
            titleLabel.adjustsFontSizeToFitWidth = true
        } else {
            titleLabel.text = hour
        }
        currentTemperature = Int(weather.temperature)
        temperatureLabel.text = " \(convertor.tempOnCurrentUnits(Double(currentTemperature))) " + "°" //Temperature
        
        var isDay = "Day"
        if Int(hour)! >= 18 || Int(hour)! <= 6 {        //Day or night check
            isDay = "Night"
        } else {
            isDay = "Day"
        }
        
        switch weather.icon { //Changing icon based on weather
        case "rain":
            imageView.image = UIImage(named: "rainy" + isDay)
        case "snow", "sleet":
            imageView.image = UIImage(named: "snowy" + isDay)
        case "cloudy", "partly-cloudy-day", "partly-cloudy-night":
            imageView.image = UIImage(named: "cloudy" + isDay)
        default:
            imageView.image = UIImage(named: isDay)
        }
    }
    
    func getDate(from time: Date?, dateFormat: DateFormat, _ timeZone: String?) -> String { //To get hour or day of the week as string from time
        guard let myTime = time else {
            return ""
        }
        
        let formatter = DateFormatter()
        formatter.locale = NSLocale(localeIdentifier: Locale.preferredLanguages.first!) as Locale
        if dateFormat == .hourly { formatter.timeZone = TimeZone(identifier: timeZone!) }
        switch dateFormat {
        case .daily:
            formatter.dateFormat = "EEE"
        default:
            formatter.dateFormat = "HH"
        }
        return formatter.string(from: myTime)
    }
    
    private func refreshValues() {
        temperatureLabel.text = " \(convertor.tempOnCurrentUnits(Double(currentTemperature))) " + "°" //Temperature
    }
}

struct DateFormat: OptionSet {
    let rawValue: Int
    
    static let daily  = DateFormat(rawValue: 1 << 0)
    static let hourly = DateFormat(rawValue: 1 << 1)
}

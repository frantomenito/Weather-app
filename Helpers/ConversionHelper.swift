//
//  ConversionHelper.swift
//  WeatherApp
//
//  Created by Dmytro Maksymyak on 31.08.2021.
//

import Foundation
import Combine

class ConversionHelper {
    public let passthroughtSubject = PassthroughSubject<Units, Never>()

    static var shared: ConversionHelper = {
        return ConversionHelper()
    }()
    
    enum Units: Encodable, Decodable {
        case Fahrenheit
        case Celsius
    }
    
    private var currentUnit = Units.Celsius {
        didSet {
            if currentUnit != oldValue {
                passthroughtSubject.send(currentUnit)
            }
        }
    }
    
    public func setUnitsTo(_ newUnits: Units) {
        currentUnit = newUnits
        do {
            UserDefaults.standard.set(try PropertyListEncoder().encode(newUnits), forKey: "units")

        } catch { print("Error saving units")}
    }
    
    public func loadSavedUnits() {
        if let data = UserDefaults.standard.value(forKey: "units") as? Data {
            do {
                currentUnit = try PropertyListDecoder().decode(Units.self, from: data)
            } catch { print("Error loading units") }
        }
    }
    
    public func getCurrentUnits() -> Units {
        return currentUnit
    }
    public func tempOnCurrentUnits(_ temperature: Double) -> Int {
        switch currentUnit {
        case .Celsius:
            let measurment = Measurement(value: temperature, unit: UnitTemperature.celsius)
            return Int(measurment.value.rounded())
        case .Fahrenheit:
            var measurment = Measurement(value: temperature, unit: UnitTemperature.celsius)
            measurment.convert(to: .fahrenheit)
            return Int(measurment.value.rounded())
        }
    }
}

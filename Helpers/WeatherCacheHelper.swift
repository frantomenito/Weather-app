//
//  WeatherCacheHelper.swift
//  WeatherApp
//
//  Created by Dmytro Maksymyak on 24.03.2022.
//

import Foundation
import MapKit

class WeatherCacheHelper {
    static let shared = WeatherCacheHelper()
    private var cache = NSCache<MKMapItem, WeatherResponse>()
    
    public func getWeather(_ location: MKMapItem, completion: @escaping (WeatherResponse?) -> Void) {
        if let weather = cache.object(forKey: location) {
            if Calendar.current.isDateInToday(Date(timeIntervalSince1970: TimeInterval(weather.currently.time))) {
                completion(weather)
            }
        } else {
            completion(nil)
        }
    }
    public func cacheWeather(_ location: MKMapItem, _ weather: WeatherResponse) {
        cache.setObject(weather, forKey: location)
    }
}

//
//  WeatherManagerHelper.swift
//  WeatherApp
//
//  Created by Dmytro Maksymyak on 08.03.2022.
//

import Foundation
import MapKit

class WeatherManagerHelper {
    private var location = MKMapItem()
    
    private func getURL(longitude: String, latitude: String) -> URL {
        var url: URL
        
        var urlString = String()
        let mainURL = "https://dark-sky.p.rapidapi.com/"
        let location = latitude + "," + longitude
        let lang = "?lang=en"
        let params = "&units=ca&exclude=timezone%2Coffset%2Cminutely%2Clatitude%2Clongitude%2Cflags"
        
        urlString = mainURL + "\(location)" + lang + params
        url = URL(string: urlString)!
        
        return url
    }
        
    //MARK: Getting data functions
    
    func loadData(location: MKMapItem?, completionHandler: @escaping ([DailyWeatherData], [HourlyWeatherData], CurrentWeather, String) -> Void) {
        let headers = [
            "x-rapidapi-key": APIManager().apiKey,
            "x-rapidapi-host": "dark-sky.p.rapidapi.com"
        ]
        guard let location = location else { return }
        WeatherCacheHelper.shared.getWeather(location, completion: { [self] weather in
            if let weather = weather {
                completionHandler(weather.daily.data, weather.hourly.data, weather.currently, weather.timezone) //If cached, load cahe
            } else {//if not cached, download
                let long = "\(Double(location.placemark.coordinate.longitude))"
                let lat = "\(Double(location.placemark.coordinate.latitude))"
                
                let request = NSMutableURLRequest(url: getURL(longitude: long, latitude: lat),
                                                  cachePolicy: .useProtocolCachePolicy,
                                                  timeoutInterval: 10.0)
                request.httpMethod = "GET"
                request.allHTTPHeaderFields = headers
                
                let session = URLSession.shared
                let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                    guard let data = data, error == nil else {
                        print("Error while getting data")
                        return
                    }
                    
                    var jsonData: WeatherResponse?
                    do {
                        jsonData = try JSONDecoder().decode(WeatherResponse.self, from: data)
                    } catch {
                        print("error \(error)")
                    }
                    
                    guard let result = jsonData else {
                        return
                    }
                    print("Downloaded location: \(location.name!)")
                    WeatherCacheHelper.shared.cacheWeather(location, result)
                    completionHandler(result.daily.data, result.hourly.data, result.currently, result.timezone)
                })
                dataTask.resume()
            }
        })
    }
}

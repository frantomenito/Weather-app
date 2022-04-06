//
//  APIManager.swift
//  WeatherApp
//
//  Created by Dmytro Maksymyak on 05.04.2022.
//

import Foundation

struct APIManager {
    var apiKey: String {
        guard let token = Keys.privateKey else {
            assertionFailure("Please fill the token in Keys.swift")
            return ""
        }
        return token
    }
}

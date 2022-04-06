//
//  ColorHelper.swift
//  WeatherApp
//
//  Created by Dmytro Maksymyak on 12.03.2022.
//

import Foundation
import UIKit
import Combine

class ColorHelper {
    
    static var shared: ColorHelper = {
        return ColorHelper()
    }()
    private var backgroundColor = UIColor(red: 200/256, green: 200/256, blue: 220/256, alpha: 0.4) {
        didSet {
            if backgroundColor != oldValue {
                passthroughtSubject.send(backgroundColor)
            }
        }
    }
    private var secondaryColor = #colorLiteral(red: 0.6862619519, green: 0.807577312, blue: 0.9968659282, alpha: 1)
    private var mainColor = #colorLiteral(red: 0.8320744091, green: 0.9244012037, blue: 1, alpha: 1)
    public let passthroughtSubject = PassthroughSubject<UIColor, Never>()
    
    public func getBackgroundColor() -> UIColor {
        return backgroundColor
    }
    
    public func getGradient() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.colors = [secondaryColor.cgColor, mainColor.cgColor]
        gradient.locations = [0.0, 0.8]
        
        return gradient
    }
    
    public func animateGradient(_ gradient: CAGradientLayer, basedOn weather: CurrentWeather?) {
        setColors(basedOn: weather)
        
        let animation = CABasicAnimation(keyPath: "colors")
        
        animation.fromValue = gradient.colors
        animation.toValue = [secondaryColor.cgColor, mainColor.cgColor]
        animation.duration = 0.5
        animation.isRemovedOnCompletion = true
        animation.fillMode = .forwards
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        gradient.colors = [secondaryColor.cgColor, mainColor.cgColor]

        gradient.add(animation, forKey: "gradient")
    }
    
    public func setColors(basedOn weather: CurrentWeather?) {
        let hour = Calendar.current.component(.hour, from: Date())
        guard let weather = weather else {
            if hour < 8 || hour > 22 {
                secondaryColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.6235973652, alpha: 1)
                mainColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.8527455363, alpha: 1)
                backgroundColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 0.2)
            } else {
                backgroundColor = UIColor(red: 200/256, green: 200/256, blue: 240/256, alpha: 0.4)
                secondaryColor = #colorLiteral(red: 0.6862619519, green: 0.807577312, blue: 0.9968659282, alpha: 1)
                mainColor = #colorLiteral(red: 0.8320744091, green: 0.9244012037, blue: 1, alpha: 1)
            }
            return
        }
        print(weather.icon.lowercased())
        switch weather.icon {
        case let str where str.lowercased().contains("snow") || str.lowercased().contains("fog"):
            secondaryColor = #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1)//Top
            mainColor = #colorLiteral(red: 0.8039215686, green: 0.8039215686, blue: 0.8039215686, alpha: 1)//Bottom
            backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 0.2)

        case let str where str.lowercased().contains("clear"):
            if hour < 8 || hour > 22 {
                secondaryColor = #colorLiteral(red: 0.07843137255, green: 0.07843137255, blue: 0.2549019608, alpha: 1)
                mainColor = #colorLiteral(red: 0.1764705882, green: 0.1764705882, blue: 0.2941176471, alpha: 1)
                backgroundColor = #colorLiteral(red: 0.3137254902, green: 0.3137254902, blue: 0.5490196078, alpha: 0.2)

            } else {
                secondaryColor = #colorLiteral(red: 0.4099879625, green: 0.7068766452, blue: 0.9764705896, alpha: 1)
                mainColor = #colorLiteral(red: 0.699727732, green: 0.9311354844, blue: 0.9764705896, alpha: 1)
                backgroundColor = #colorLiteral(red: 0.1826500526, green: 0.6718048949, blue: 0.9764705896, alpha: 0.2)
            }
        case let str where str.lowercased().contains("overcast") || str.lowercased().contains("rain") || str.lowercased().contains("cloudy") || str.contains("drizzle"):
            if hour < 8 || hour > 22 {
                secondaryColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
                mainColor = #colorLiteral(red: 0.3135117751, green: 0.579887977, blue: 0.7568627596, alpha: 1)
                backgroundColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.9411764706, alpha: 0.2)

            } else {
                secondaryColor = #colorLiteral(red: 0.6666666667, green: 0.7450980392, blue: 0.853784948, alpha: 1)
                mainColor = #colorLiteral(red: 0.521186882, green: 0.7147926384, blue: 0.8588997367, alpha: 1)
                backgroundColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.9411764706, alpha: 0.2)
            }
        default:
            if hour < 8 || hour > 22 {
                secondaryColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.6235973652, alpha: 1)
                mainColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.8527455363, alpha: 1)
                backgroundColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 0.2)
            } else {
                backgroundColor = UIColor(red: 200/256, green: 200/256, blue: 240/256, alpha: 0.4)
                secondaryColor = #colorLiteral(red: 0.6862619519, green: 0.807577312, blue: 0.9968659282, alpha: 1)
                mainColor = #colorLiteral(red: 0.8320744091, green: 0.9244012037, blue: 1, alpha: 1)
            }
        }
    }
}

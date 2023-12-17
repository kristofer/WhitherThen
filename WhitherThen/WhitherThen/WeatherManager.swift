//
//  WeatherManager.swift
//  WhitherThen
//
//  Created by Kristofer Younger on 12/14/23.
//

import Foundation
import WeatherKit
import CoreLocation

@MainActor class WeatherManager: ObservableObject {
    @Published var weather: Weather?
    
    func getWeather(_ loc: CLLocation) async {
            do {
                weather = try await Task.detached(priority: .userInitiated) {
                    let lat = loc.coordinate.latitude
                    let lon = loc.coordinate.longitude
                    return try await WeatherService.shared.weather(for: .init(latitude: lat, longitude: lon))
                    //36.49183, -78.38987 Coordinates for Steele Creek Marina
                }.value
            } catch {
                fatalError("\(error)")
            }
        }
    
    var symbol: String {
            weather?.currentWeather.symbolName ?? "tornado"
        }
    var temp: String {
            let temp =
            weather?.currentWeather.temperature.converted(to: .fahrenheit).formatted(.measurement(width: .narrow))
            
            let convert = temp
            return convert ?? "Temperature"
            
        }
    var windDir: String {
        let dir =
        weather?.currentWeather.wind.compassDirection.description//.formatted(.measurement(width: .abbreviated, usage: .asProvided))
        //let convert = dir?.converted(to: .degrees).description
        return dir ?? "Direction"
    }
    var windDeg: String {
        let dir =
        weather?.currentWeather.wind.direction.description
        //let convert = dir?.converted(to: .degrees)
        return dir ?? "Degrees"
    }
    var windDirection: Double {
        let dir = weather?.currentWeather.wind.direction.value
        return dir ?? 0.0
    }
    
    var windSpd: String {
        let dir =
        weather?.currentWeather.wind.speed.formatted(.measurement(width: .abbreviated, usage: .general)) //.converted(to: .knots).formatted(.measurement(width: .narrow))
        return dir ?? "Speed"
    }
    var windGusts: String {
        let dir =
        weather?.currentWeather.wind.gust?.converted(to: .knots).formatted(.measurement(width: .narrow))
        return dir ?? "Gusts"
    }
}

//
//  LocationManager.swift
//  Schooner
//
//  Created by Kristofer Younger on 1/19/22.
//

import Foundation
// home
//Latitude:    35.978693
//Longitude:   -78.989141
// steele creek
// 36.491778, -78.389869

import MapKit
import CoreLocation
import CoreLocationUI

class AverageArray: NSObject, ObservableObject {
    static let maxl = 8
    var vals = Array(repeating: 0.0, count: maxl)
    @Published var average: Double
    
    override init() {
        average = 0.0
        vals = Array(repeating: 0.0, count: AverageArray.maxl)
    }
    func add(_ d: Double) {
        vals.removeFirst()
        vals.append(d)
        self.average = Double(vals.reduce(0, +) / Double(AverageArray.maxl))
    }
    func avg() -> Double {
        return self.average
    }
}

class LocationManager: NSObject,CLLocationManagerDelegate, ObservableObject {
    
    @Published var region = MKCoordinateRegion()
    //@Published var location: CLLocationCoordinate2D?
    @Published var here: CLLocation?
    @Published var speedArray = AverageArray()
    @Published var headingArray = AverageArray()
    @Published var avgspeed = "0.0"
    @Published var avgheading = "0.0"
    @Published var degrees = 0.0
    @Published var currenttime = "xx:yy"


    
    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        // We've been passed a cached result so ignore and continue.
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        // horizontalAccuracy < 0 indicates invalid result so ignore and continue.
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        // Calculate the distance between the new and previous locations.
        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        if let here = self.here { // location is my previously stored value.
            distance = newLocation.distance(from: here)
            //print("distance from last \(distance)")
        }
        // If newLocation is more accurate than the previous (if previous exists) then use it.
        if here == nil || here!.horizontalAccuracy > newLocation.horizontalAccuracy {
            //lastLocationError = nil
            here = newLocation

            // When newLocation's accuracy is better than our desired accuracy then stop.
//            if newLocation.horizontalAccuracy <= manager.desiredAccuracy {
//                manager.stopUpdatingLocation()
//            }
        } else if distance < 5 {
            let timeInterval = newLocation.timestamp.timeIntervalSince(here!.timestamp)
            if timeInterval > 10 {
                //manager.stopUpdatingLocation()
            }
        }

        self.speedArray.add(newLocation.speed < 0 ? 0.0 : newLocation.speed)
        self.headingArray.add(newLocation.course < 0 ? 0.0 : newLocation.course)
        self.avgspeed = self.speedFormat(self.speedArray.average * 1.944)
        self.degrees = 360 - self.headingArray.average
        self.avgheading = String(format: "%.0f\u{00B0}", self.headingArray.average)
        self.currenttime = newLocation.timestamp.formatted(date: .omitted, time: .shortened)
        //print(newLocation)
//        locations.last.map {
//            region = MKCoordinateRegion( center: $0.coordinate, latitudinalMeters: CLLocationDistance(exactly: 5000)!, longitudinalMeters: CLLocationDistance(exactly: 5000)!)
//
//        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    
    func requestLocation() {
        //manager.requestLocation()
        manager.startUpdatingLocation()
    }

    func speedFormat(_ d: Double) -> String{
        String(format: "%.1f", d)
    }
}

//
//  Walk.swift
//  WhitherThen
//
//  Created by Kristofer Younger on 11/27/23.
//

import Foundation
import SwiftData
import CoreLocation
import CoreLocationUI

// two kinds for now, "Walk" and "Sail" :-)

let WALKTAG = "Walk"
let SAILTAG = "Sail"



@Model
final class Walk: ObservableObject {
    //@Attribute(.unique)
    var id: String = UUID().uuidString
    var startstamp: Date = Date()
    var stopstamp: Date = Date()
    var distance: Double = 0.0
    var waypoints: [Waypoint]? = []
    var kind: String = ""
    var steps: Int = 0
    
    init(startstamp: Date, kind: String) {
        self.startstamp = startstamp
        self.stopstamp = startstamp
        self.distance = 0.0
        self.steps = 0
        self.waypoints = []
        self.kind = kind
    }
    
    static func EmptyWalk() -> Walk {
        return Walk(startstamp: Date(), kind: WALKTAG)
    }
    
    var duration: TimeInterval {
         get {
             return stopstamp.timeIntervalSince(startstamp)
         }
     }
     
    func addDistance(_ distance: Double) {
        self.distance += distance
    }
    
    func addSteps(_ steps: Int) {
        self.steps += steps
    }
    
     func addNewLocation(_ location: CLLocation) {
         let newwpt = Waypoint(loc: location)
             waypoints!.append(newwpt)
     }

}

@Model
final class Waypoint: ObservableObject {
    var id: String = UUID().uuidString
    var timestamp: Date = Date()
    var lat: Double = 0.0
    var lon: Double = 0.0
    var alt: Double = 0.0
    var walk: Walk? = nil
    
    init(loc: CLLocation) {
        self.timestamp = loc.timestamp
        self.alt = loc.altitude
        self.lat = loc.coordinate.latitude
        self.lon = loc.coordinate.longitude
    }
    
    func makeLocation() -> CLLocation {
        return CLLocation(latitude: self.lat, longitude: self.lon)
    }
}

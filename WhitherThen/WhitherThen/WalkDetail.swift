//
//  WalkDetail.swift
//  WhitherThen
//
//  Created by Kristofer Younger on 11/27/23.
//

import SwiftUI
import MapKit
import CoreLocation

// , CLLocationManagerDelegate, MKMapViewDelegate

final class WalkDetailVM: NSObject, ObservableObject, CLLocationManagerDelegate {

    var walk: Walk
    var locMgr = CLLocationManager()
    @Published var isTracking: Bool
    
    init(walk: Walk) {
        self.walk = walk
        self.isTracking = false
        super.init()

        self.locMgr.delegate = self
        self.locMgr.activityType = .fitness
        self.locMgr.desiredAccuracy = kCLLocationAccuracyBest
        
        self.locMgr.requestAlwaysAuthorization()
        

    }
    
    func startWalk() {
        if isTracking {
            locMgr.stopUpdatingLocation()
            walk.stopstamp = Date()
            isTracking = false
        } else {
            locMgr.startUpdatingLocation()
            walk.startstamp = Date()
            isTracking = true
        }
        
        //isTracking.toggle()

    }
    func stopWalk() {
        //saveContext()
    }
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
            for location in locations {
                if let newLocation = location as? CLLocation {
                    if newLocation.horizontalAccuracy > 0 {
                        // Only set the location on and region on the first try
                        // This may change in the future
                        if walk.waypoints.count <= 0 {
                            //mapView.setCenterCoordinate(newLocation.coordinate, animated: true)
                            
//                            let region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 1000, 1000)
//                            mapView.setRegion(region, animated: true)
                        }
                        let waypoints = walk.waypoints as [Waypoint]
                        if let oldWaypoint = waypoints.last {
                            let oldLoc = oldWaypoint.makeLocation()
                            let delta: Double = newLocation.distance(from: oldLoc)
                            walk.addDistance(delta)
                        }
                        
                        walk.addNewLocation(newLocation)
                        print("adding a location")
                    }
                }
            }
            //updateDisplay()
    }

    func weLive() -> Bool {
        return self.isTracking
    }

}

struct WalkDetail: View {
    @ObservedObject var walk: Walk
    var vm: WalkDetailVM
    
    init(walk: Walk) {
        self.walk = walk
        self.vm = WalkDetailVM(walk: walk)
    }
    
    var body: some View {
        Button("Start", action: {vm.startWalk()})
        Button("Stop", action: {vm.stopWalk()})
        
        Text("Walk at \(walk.startstamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
        Text("Walking? " + String(vm.isTracking))
    }
    

}

#Preview {
    WalkDetail(walk: Walk.EmptyWalk())
}

//
//  WhitherThenApp.swift
//  WhitherThen
//
//  Created by Kristofer Younger on 11/27/23.
//

import SwiftUI
import SwiftData
import CoreLocation
import MapKit

class LocationDataManager : NSObject, ObservableObject, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var walk: Walk?
    @Published var errorAlertString: String?
    @Published var region: MKCoordinateRegion?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func setWalk(_ walkToChange: Walk) {
        self.walk = walkToChange
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:  // Location services are available.
            authorizationStatus = .authorizedWhenInUse
            locationManager.requestLocation()
            
            break
            
        case .restricted, .denied:  // Location services currently unavailable.
            authorizationStatus = .restricted
            break
            
        case .notDetermined:        // Authorization not determined yet.
            authorizationStatus = .notDetermined
            manager.requestWhenInUseAuthorization()
            break
            
        default:
            break
        }
    }
    
    func startCollecting(_ walk: Walk) {
        self.walk = walk
        self.locationManager.startUpdatingLocation()
    }
    func stopCollecting(_ walk: Walk) {
        self.walk = walk
        self.locationManager.stopUpdatingLocation()
        walk.stopstamp = Date()
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // RELIES on self.walk to be set...
        if let walk = self.walk {
            for location in locations {
                if let newLocation = location as? CLLocation {
                    if newLocation.horizontalAccuracy > 0 {
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
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.errorAlertString = "error: \(error.localizedDescription)"
        print(self.errorAlertString ?? "location manager did fail...")
    }
    
    func setMapRegionOnce(_ loc: CLLocation ) {
        self.region = MKCoordinateRegion(center: loc.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        
        // Only set the location on and region on the first try
        // This may change in the future
        //        if walk.waypoints.count <= 0 {
        //            //mapView.setCenterCoordinate(newLocation.coordinate, animated: true)
        //            // mapView.setRegion(region, animated: true)
        //        }
        
    }
    
}


@main
struct WhitherThenApp: App {
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Walk.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

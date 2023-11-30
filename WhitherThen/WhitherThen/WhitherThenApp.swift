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
import CoreMotion

@MainActor
class LocationDataManager : NSObject, ObservableObject, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var walk: Walk?
    @Published var walking: Bool = false
    @Published var points: Int = 0

    @Published var errorAlertString: String?
    @Published var route: MKPolyline?
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 36.97,
                                       longitude: -78.99),
        latitudinalMeters: 500,
        longitudinalMeters: 500
    )
    
    /// Provides to create an instance of the CMMotionActivityManager.
    private let activityManager = CMMotionActivityManager()
    /// Provides to create an instance of the CMPedometer.
    private let pedometer = CMPedometer()

    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //locationManager.distanceFilter = 15;
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
        self.walking = true
        self.points = 0
        self.locationManager.startUpdatingLocation()
//         locationManager.allowsBackgroundLocationUpdates = true
//        locationManager.showsBackgroundLocationIndicator = true
        if CMPedometer.isStepCountingAvailable() {
            pedometer.startUpdates(from: Date()) { pedometerData, error in
                guard let pedometerData = pedometerData, error == nil else { return }
                DispatchQueue.main.async {
                    walk.addSteps(pedometerData.numberOfSteps.intValue)
                }
            }
        }
    }
    func stopCollecting(_ walk: Walk) {
        //self.walk = walk
        self.walking = false
        self.locationManager.stopUpdatingLocation()
        walk.stopstamp = Date()
        if CMPedometer.isStepCountingAvailable() {
            pedometer.stopUpdates()
        }
        
    }
    func update(_ walk: Walk) {
        if self.walk != walk {
            self.walk = walk
        }
        _ = self.polyLine()
        self.region = self.mapRegion(walk: walk)
    }
    
    func locString(loc: CLLocation) -> String {
        return String(format: "lat %.6f", loc.coordinate.latitude)
        + " - "
        + String(format: "lon %.6f", loc.coordinate.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // RELIES on self.walk to be set...
        if let walk = self.walk {
            print("how many waypoints: \(locations.count)")
            for location in locations {
                if let newLocation = location as? CLLocation {
                    self.points += 1
                    if walk.waypoints.isEmpty {
                        walk.waypoints.append(Waypoint(loc: newLocation))
                    }
                    if newLocation.horizontalAccuracy > 0 {
                        self.errorAlertString = locString(loc: newLocation)
                        let waypoints = walk.waypoints.sorted { $0.timestamp < $1.timestamp } as [Waypoint]
                        print("waypoints: \(waypoints.count)")
                        if let oldWaypoint = waypoints.last {
                            let oldLoc = oldWaypoint.makeLocation()
                            let delta: Double = newLocation.distance(from: oldLoc)
                            print("DELTA: \(delta)")
                            if delta > 3.0 {
                                walk.addDistance(delta)
                                walk.addNewLocation(newLocation)
                                self.errorAlertString?.append(" adding a location ∆ \(delta)")
                            } else {
                                self.errorAlertString = " IGNORING a location ∆ \(delta)"
                            }
                        
                        }
                        
                    }
                }
            }
            self.update(walk)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.errorAlertString = "error: \(error.localizedDescription)"
        print(self.errorAlertString ?? "location manager did fail...")
    }
    
//    func setMapRegionOnce(_ loc: CLLocation ) {
//        self.region = MKCoordinateRegion(center: loc.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
//        
//        // Only set the location on and region on the first try
//        // This may change in the future
//        //        if walk.waypoints.count <= 0 {
//        //            //mapView.setCenterCoordinate(newLocation.coordinate, animated: true)
//        //            // mapView.setRegion(region, animated: true)
//        //        }
//        
//    }
    
    func polyLine() -> MKPolyline {
        if let walk = self.walk {
            var coordinates: [CLLocationCoordinate2D] = []
            let sortedwaypts = walk.waypoints.sorted { $0.timestamp > $1.timestamp }
            for waypt in sortedwaypts {
                let coord = waypt.makeLocation().coordinate
                coordinates.append(coord)
            }
            //print("making polyline \(walk.waypoints.count) pts")
            route = MKPolyline(coordinates: &coordinates, count: coordinates.count)
            return route!
        }
        route = MKPolyline()
        return route!
    }
    
    // This feels like it could definitely live somewhere else
    // I am not sure yet where this function lives
    func mapRegion(walk: Walk) -> MKCoordinateRegion {
        if let startLoc = walk.waypoints.first {
            let startLocation = startLoc.makeLocation()
            var minLatitude = startLocation.coordinate.latitude
            var maxLatitude = startLocation.coordinate.latitude
            
            var minLongitude = startLocation.coordinate.longitude
            var maxLongitude = startLocation.coordinate.longitude
            
            for loc in walk.waypoints {
                let location = loc.makeLocation()

                if location.coordinate.latitude < minLatitude {
                    minLatitude = location.coordinate.latitude
                }
                if location.coordinate.latitude > maxLatitude {
                    maxLatitude = location.coordinate.latitude
                }
                
                if location.coordinate.longitude < minLongitude {
                    minLongitude = location.coordinate.longitude
                }
                if location.coordinate.latitude > maxLongitude {
                    maxLongitude = location.coordinate.longitude
                }
            }
            
            let center = CLLocationCoordinate2D(latitude: (minLatitude + maxLatitude)/2.0,
                                                longitude: (minLongitude + maxLongitude)/2.0)
            
            // 10% padding need more padding vertically because of the toolbar
            let span = MKCoordinateSpan(latitudeDelta: (maxLatitude - minLatitude)*1.3,
                longitudeDelta: (maxLongitude - minLongitude)*1.1)
        
            return MKCoordinateRegion(center: center, span: span)
        }
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 36.97,
                                           longitude: -78.99),
            latitudinalMeters: 100,
            longitudinalMeters: 100
        )
    }
    
//    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
//        if let polyLine = overlay as? MKPolyline {
//            let renderer = MKPolylineRenderer(polyline: polyLine)
//            renderer.strokeColor = UIColor(hue:0.88, saturation:0.46, brightness:0.73, alpha:0.75)
//            renderer.lineWidth = 6
//            return renderer
//        }
//        return nil
//    }
    
    
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
    
    @StateObject var locationDataManager = LocationDataManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        .environmentObject(locationDataManager)
    }
}

//
//  WalkDetail.swift
//  WhitherThen
//
//  Created by Kristofer Younger on 11/27/23.
//

import SwiftUI
import MapKit
import CoreLocation

struct WalkDetail: View {
    @ObservedObject var walk: Walk
    @StateObject var locationDataManager = LocationDataManager()

    init(walk: Walk) {
        self.walk = walk
    }
    
    var body: some View {
            
        VStack {
            switch locationDataManager.locationManager.authorizationStatus {
            case .authorizedWhenInUse:  // Location services are available.
                HStack {
                    Button("Start", action: {locationDataManager.startCollecting(walk)})
                        .buttonStyle(.bordered)
                        .tint(.green)
                    Text("Pts: \(walk.waypoints.count)")
                    Spacer()
                    Button("Stop", action: {locationDataManager.stopCollecting(walk)})
                        .buttonStyle(.bordered)
                        .tint(.red)
                }
                .padding()
                // Insert code here of what should happen when Location services are authorized
                Text("Your current location is:")
                Text("Latitude: \(locationDataManager.locationManager.location?.coordinate.latitude.description ?? "Error loading")")
                Text("Longitude: \(locationDataManager.locationManager.location?.coordinate.longitude.description ?? "Error loading")")
                Map() {
                    MapPolyline(locationDataManager.polyLine())
                    .stroke(.blue, lineWidth: 8)
                }
                .mapControls {
                            MapUserLocationButton()
                        }

                            .frame(width: 400, height: 300)
            case .restricted, .denied:  // Location services currently unavailable.
                // Insert code here of what should happen when Location services are NOT authorized
                Text("Current location data was restricted or denied.")
            case .notDetermined:        // Authorization not determined yet.
                Text("Finding your location...")
                ProgressView()
            default:
                ProgressView()
            }
        }
    }
    
//    func updateDisplay() {
//        if let walk = self.walk {
//            if let region = self.mapRegion(walk) {
//                mapView.setRegion(region, animated: true)
//            }
//        }
//        
//        mapView.removeOverlays(mapView.overlays)
//        mapView.addOverlay(polyLine())
//    }


}

#Preview {
    WalkDetail(walk: Walk.EmptyWalk())
}

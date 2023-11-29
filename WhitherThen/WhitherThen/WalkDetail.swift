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
    @EnvironmentObject var locationDataManager: LocationDataManager
    
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
                    Button("Draw", action: {locationDataManager.update(walk)})
                        .buttonStyle(.bordered)
                        .tint(.gray)
                    Button("Stop", action: {locationDataManager.stopCollecting(walk)})
                        .buttonStyle(.bordered)
                        .tint(.red)
                }
                .padding()
                // Insert code here of what should happen when Location services are authorized
                Text("Your current location is:")
                Text("Latitude: \(locationDataManager.locationManager.location?.coordinate.latitude.description ?? "Error loading")")
                Text("Longitude: \(locationDataManager.locationManager.location?.coordinate.longitude.description ?? "Error loading")")
                Text("Distance (m) \(walk.distance) \(walk.duration)")
                Map() {
                    MapPolyline(locationDataManager.route ?? MKPolyline())
                        .stroke(.blue, lineWidth: 4)
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
        .onAppear(){
            locationDataManager.update(walk)
        }
    }
    
}

#Preview {
    WalkDetail(walk: Walk.EmptyWalk())
}

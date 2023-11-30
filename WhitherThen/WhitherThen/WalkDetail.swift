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
    @Environment(\.modelContext) private var context
    
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
                    Text("Pts: \(walk.waypoints.count) Walking: \(locationDataManager.walking)" as String)
                    Spacer()
                    Button("Draw", action: {locationDataManager.update(walk)})
                        .buttonStyle(.bordered)
                        .tint(.gray)
                    Button("Stop", action: {
                        locationDataManager.stopCollecting(walk)
                        if context.hasChanges {
                            try? context.save()
                        }
                    })
                        .buttonStyle(.bordered)
                        .tint(.red)
                }
                .padding()
                // Insert code here of what should happen when Location services are authorized
                Text("Your current location is:")
//                Text("Latitude: \(locationDataManager.locationManager.location?.coordinate.latitude.description ?? "Error loading")")
//                Text("Longitude: \(locationDataManager.locationManager.location?.coordinate.longitude.description ?? "Error loading")")
                Text(locationDataManager.lastLocationString())
                Text("Distance (m) \(walk.distance) Time \(walk.duration)")
                Text("Steps (m) \(walk.steps) Points: \(locationDataManager.points)")
                Text(locationDataManager.errorAlertString ?? "no msg")

Divider()
                Map(
//                    coordinateRegion: $locationDataManager.region,
//                    showsUserLocation: true,
//                    userTrackingMode: .constant(.follow)
                ) {
                    MapPolyline(locationDataManager.route ?? MKPolyline())
                        .stroke(.blue, lineWidth: 4)
                }
                .mapControls {
                    MapUserLocationButton()
                }
                .frame(width: 400, height: 300)
                Button("Reset the Walk", action: {
                    locationDataManager.stopCollecting(walk)
                    walk.waypoints = []
                    walk.steps = 0
                    if context.hasChanges {
                        try? context.save()
                    }
                    locationDataManager.update(walk)
                })
                    .buttonStyle(.bordered)
                    .tint(.red)

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

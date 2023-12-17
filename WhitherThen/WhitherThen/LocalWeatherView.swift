//
//  LocalWeatherView.swift
//  WhitherThen
//
//  Created by Kristofer Younger on 12/14/23.
//

import SwiftUI
import MapKit
import WeatherKit

struct LocalWeatherView: View {
    @EnvironmentObject var locationDataManager: LocationDataManager
    @EnvironmentObject var weatherManager: WeatherManager

    @State var region = MKCoordinateRegion(
        center: .init(latitude: 36.49183, longitude: -78.38987),
        span: .init(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    @State private var showMarina = false

    var body: some View {
        VStack(alignment: .leading) {
            Map(
                coordinateRegion: $region,
                showsUserLocation: true,
                userTrackingMode: .constant(.follow)
            )
            HStack {
                Label(weatherManager.temp, systemImage: weatherManager.symbol)
                Text("F")
            }
            Text("Wind ") + Text(weatherManager.windDir)
            Text("Speed ") + Text(weatherManager.windSpd)
            Text("Gusts ") + Text(weatherManager.windGusts)
            Divider()
            Button("SteeleCreekMarina") {
                showMarina.toggle()
            }
            .font(.body)
            .buttonStyle(.bordered)
        }
        .font(.largeTitle)
        .foregroundColor(.green)
        .padding()
        .sheet(isPresented: $showMarina, content: SteeleCreekModalView.init)
    }

}

struct SteeleCreekModalView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var weatherManager: WeatherManager
    @EnvironmentObject var locationDataManager: LocationDataManager
    init() {}
    
    func getMarinaWeather() async {
            do {
                weatherManager.weather = try await Task.detached(priority: .userInitiated) {
                    return try await WeatherService.shared.weather(for: .init(latitude: 36.49183, longitude: -78.38987))
                    //36.49183, -78.38987 Coordinates for Steele Creek Marina
                }.value
            } catch {
                fatalError("\(error)")
            }
        }
    
     var body: some View {
        VStack(alignment: .leading) {
            Text("Steele Creek Marina Weather")
            Divider()
            HStack {
                Label(weatherManager.temp, systemImage: weatherManager.symbol)
                Text("F")
            }
            Divider()
            AnemometerView()
            Divider()
            Text("Wind: ") + Text(weatherManager.windDir)
            Text("Bearing: ") + Text(weatherManager.windDeg)
            Text("Speed: ") + Text(weatherManager.windSpd)
            Text("Gusts: ") + Text(weatherManager.windGusts)
            Divider()
        }
        .font(.headline)
        .foregroundColor(.green)
        .padding()
        .task {
            await getMarinaWeather()
        }

        Button("Dismiss Modal") {
            locationDataManager.requestLocation()
            dismiss()
        }
    }
}


struct AnemometerView: View {
    @EnvironmentObject var weatherManager: WeatherManager

    //shape for the indicator arrow
    struct Triangle: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
            
            return path
        }
    }
    
    struct MyShape : Shape {
        var sections : Int
        var lineLengthPercentage: CGFloat
        
        func path(in rect: CGRect) -> Path {
            let radius = rect.width / 2
            let degreeSeparation : Double = 360.0 / Double(sections)
            var path = Path()
            for index in 0..<Int(360.0/degreeSeparation) {
                let degrees = Double(index) * degreeSeparation
                let center = CGPoint(x: rect.midX, y: rect.midY)
                let innerX = center.x + (radius - rect.size.width * lineLengthPercentage / 2) * CGFloat(cos(degrees / 360 * Double.pi * 2))
                let innerY = center.y + (radius - rect.size.width * lineLengthPercentage / 2) * CGFloat(sin(degrees / 360 * Double.pi * 2))
                let outerX = center.x + radius * CGFloat(cos(degrees / 360 * Double.pi * 2))
                let outerY = center.y + radius * CGFloat(sin(degrees / 360 * Double.pi * 2))
                path.move(to: CGPoint(x: innerX, y: innerY))
                path.addLine(to: CGPoint(x: outerX, y: outerY))
            }
            return path
        }
    }
    
    var body: some View {
        
        ZStack {
            GeometryReader{ geometry in
                
                let width: CGFloat = min(geometry.size.width, geometry.size.height)
                //let height = width
                Circle()
                    .fill(.black)
                    .shadow(radius: 10, x: -10, y: 10)
                
//                //STBD color
//                Circle()
//                    .trim(from: 0, to: 0.167)
//                    .stroke(Color.green, lineWidth: width/20)
//                    .padding((width/20)/2) //it gives half of the stroke width, so it is like a strokeBorder
//                    .rotationEffect(.init(degrees: 270))
//                
//                //PORT color
//                Circle()
//                    .trim(from: 0, to: 0.167)
//                    .stroke(Color.red, lineWidth: width/20)
//                    .padding((width/20)/2)
//                    .rotationEffect(.init(degrees: 210))
                
                //indicator holder
                Circle()
                    .fill(.gray)
                    .scaleEffect(x: 0.09, y: 0.09)
                
                //part of the indicator
                Circle()
                    .fill(.white)
                    .scaleEffect(x: 0.04, y: 0.04, anchor: .center)
                //angle indicators
                //long indicators
                MyShape(sections: 12, lineLengthPercentage: 0.2)
                    .stroke(Color.white, style: StrokeStyle(lineWidth: width/90))
                
                //short indicators
                MyShape(sections: 36, lineLengthPercentage: 0.1)
                    .stroke(Color.white, style: StrokeStyle(lineWidth: width/90))
                //.scaleEffect(x: 0.95, y: 0.95)
                
//                // gauge numbers <--- here
//                ForEach(GaugeMarker.labelSet()) { marker in
//                    LabelView(marker: marker, paddingValue: CGFloat(geometry.size.width * 0.80))
//                        .position(CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2))
//                }
                // gauge numbers <---
                 ForEach(GaugeMarker.labelSet()) { marker in
                     LabelView(marker: marker, geometry: geometry)
                         .position(CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2))
                 }

                //indicator arrow
                Triangle()
                    .fill(.white)
                    .scaleEffect(x: 0.04, y: 0.5, anchor: .top)
                    .rotationEffect(.init(degrees: weatherManager.windDirection))
            }
            //that centers the shape
            .aspectRatio(1, contentMode: .fit)
        }
    }
}

 
 public struct LabelView: View {
     let marker: GaugeMarker
     let geometry: GeometryProxy
     
     @State var fontSize: CGFloat = 12
     @State var paddingValue: CGFloat = 100
     
     public var body: some View {
         VStack {
             Text(marker.label)
                 .foregroundColor(Color.white)
                 //.font(Font.custom("Didot-Bold", size: fontSize))
                 // make sure the text is upright, ie undo the rotation
                 .rotationEffect(Angle(degrees: -marker.degrees))
                 .padding(.bottom, paddingValue)
         }
         // place the VStack (with the Text) at the chosen angle around the clock
         .rotationEffect(Angle(degrees: marker.degrees))
             .onAppear {
                 paddingValue = geometry.size.width * 0.7
                 fontSize = geometry.size.width * 0.05
             }
     }
 }

struct GaugeMarker: Identifiable, Hashable {
    let id = UUID()
    
    let degrees: Double
    let label: String
    
    init(degrees: Double, label: String) {
        self.degrees = degrees
        self.label = label
    }
    
    // adjust according to your needs
    static func labelSet() -> [GaugeMarker] {
        return [
            GaugeMarker(degrees: 0, label: "N"),
            GaugeMarker(degrees: 30, label: "30"),
            GaugeMarker(degrees: 60, label: "60"),
            GaugeMarker(degrees: 90, label: "E"),
            GaugeMarker(degrees: 120, label: "120"),
            GaugeMarker(degrees: 150, label: "150"),
            GaugeMarker(degrees: 180, label: "S"),

//            GaugeMarker(degrees: 240, label: "120"),
//            GaugeMarker(degrees: 270, label: "90"),
//            GaugeMarker(degrees: 300, label: "60"),
//            GaugeMarker(degrees: 330, label: "30")
            GaugeMarker(degrees: 210, label: "210"),
            GaugeMarker(degrees: 240, label: "240"),
            GaugeMarker(degrees: 270, label: "W"),
            GaugeMarker(degrees: 300, label: "300"),
            GaugeMarker(degrees: 330, label: "330")
        ]
    }
}

#Preview {
    LocalWeatherView()
}

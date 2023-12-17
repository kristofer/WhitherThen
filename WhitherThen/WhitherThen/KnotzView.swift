//
//  KnotzView.swift
//  Schooner
//
//  Created by Kristofer Younger on 1/19/22.
//

import SwiftUI

struct KnotzView: View {
    @EnvironmentObject var manager: LocationManager

    @State var speed: String = ""

    var body: some View {
        VStack(spacing: 5){
            Text("Knots")
                .font(.title)
//                .border(Color.green)
            Text("\(manager.avgspeed)")
                .font(.system(size: 144.0))
//                .border(Color.green)
            Divider()
//            Text("Direction")
//                .font(.largeTitle)
//                .border(Color.green)
            CompassView(compassHeading: manager)
                .border(Color.green)
            Text("\(manager.avgheading)")
                .font(.system(size: 108.0))
//                .border(Color.green)
            Divider()
            Text("\(manager.currenttime)")
                .font(.system(size: 64.0))
//                .border(Color.green)

        }
    }
}

struct KnotzView_Previews: PreviewProvider {
    static var previews: some View {
        KnotzView()
    }
}

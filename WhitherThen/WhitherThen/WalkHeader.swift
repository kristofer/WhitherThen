//
//  WalkHeader.swift
//  WhitherThen
//
//  Created by Kristofer Younger on 12/14/23.
//

import SwiftUI

struct WalkHeader: View {
    var walk: Walk
    let walkListDateFormat = Date.FormatStyle()
        .locale(Locale(identifier: "en_US"))
        .weekday(.abbreviated)
        .month(.abbreviated)
        .day(.defaultDigits)
        .hour().minute()
    
    var body: some View {
        HStack {
            Text(iconForKind(t: walk))
            Text(" \(walk.startstamp, format:  walkListDateFormat)")
        }
        .foregroundColor(colorForWalk(t: walk))
    }
    
    private func iconForKind(t: Walk) -> Image {
        if t.kind == SAILTAG {
            return Image(systemName: "sailboat.circle")
        } else {
            return Image(systemName: "figure.walk.circle")
        }
    }
    
    private func colorForWalk(t: Walk) -> Color {
        if t.kind == SAILTAG {
            return .blue
        } else {
            return .green
        }
    }
    
}

#Preview {
    EmptyView()
}

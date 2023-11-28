//
//  WhitherThenApp.swift
//  WhitherThen
//
//  Created by Kristofer Younger on 11/27/23.
//

import SwiftUI
import SwiftData

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

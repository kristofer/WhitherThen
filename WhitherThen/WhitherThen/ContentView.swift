//
//  ContentView.swift
//  WhitherThen
//
//  Created by Kristofer Younger on 11/27/23.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Walk.stopstamp, order: .reverse) private var walks: [Walk]
    let walkListDateFormat = Date.FormatStyle()
        .locale(Locale(identifier: "en_US"))
        .weekday(.abbreviated)
        .month(.abbreviated)
        .day(.defaultDigits)
        .hour().minute()
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(walks) { walk in
                    NavigationLink {
                        WalkDetail(walk: walk)
                    } label: {
                        Text("\(walk.startstamp, format:  walkListDateFormat)")
//Date.FormatStyle(date: walkDateFormat, time: .standard))")
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Walks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Walk", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select a Walk")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Walk(startstamp: Date(), kind: WALKTAG)
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(walks[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Walk.self, inMemory: true)
}

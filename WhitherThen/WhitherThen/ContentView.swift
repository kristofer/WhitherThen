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
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(walks) { walk in
                    NavigationLink {
                        WalkDetail(walk: walk)
                    } label: {
                        WalkHeader(walk: walk)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: {addItem(t: Walk(startstamp: Date(), kind: WALKTAG))}) {
                        Label("Add Walk", systemImage: "figure.walk.circle")
                    }
                }
                ToolbarItem {
                    Button(action: {addItem(t: Walk(startstamp: Date(), kind: SAILTAG))}) {
                        Label("Add Sail", systemImage: "sailboat.circle")
                    }
                }
            }
        } detail: {
            Text("Select a Walk")
        }
    }
    
    private func addItem(t: Walk) {
        withAnimation {
            //let newItem = Walk(startstamp: Date(), kind: WALKTAG)
            modelContext.insert(t)
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

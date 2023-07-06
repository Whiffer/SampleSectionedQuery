//
//  SampleSectionedQueryApp.swift
//  SampleSectionedQuery
//
//  Created by Robert Hartman on 7/6/23.
//

import SwiftUI
import SwiftData

@main
struct SampleSectionedQueryApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Item.self, Attribute.self])
    }
}

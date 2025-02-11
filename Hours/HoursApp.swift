//
//  HoursApp.swift
//  Hours
//
//  Created by Ömer Cem Kaya on 11.02.2025.
//

import SwiftUI

@main
struct HoursApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

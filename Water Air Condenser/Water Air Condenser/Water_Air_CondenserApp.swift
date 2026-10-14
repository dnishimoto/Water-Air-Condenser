//
//  Water_Air_CondenserApp.swift
//  Water Air Condenser
//
//  Created by David Nishimoto on 10/14/26.
//

import SwiftUI
import CoreData

@main
struct Water_Air_CondenserApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

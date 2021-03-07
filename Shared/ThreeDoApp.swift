//
//  ThreeDoApp.swift
//  Shared
//
//  Created by John Paul on 07/03/2021.
//

import SwiftUI

@main
struct ThreeDoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

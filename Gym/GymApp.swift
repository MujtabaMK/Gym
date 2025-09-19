//
//  GymApp.swift
//  Gym
//
//  Created by Mujtaba Khan on 19/09/25.
//

import SwiftUI

@main
struct GymApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

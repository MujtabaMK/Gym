//
//  ContentView.swift
//  Gym
//
//  Created by Mujtaba Khan on 19/09/25.
//

import SwiftUI
import CoreData

// MARK: - Views
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var vm: GymViewModel
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _vm = StateObject(wrappedValue: GymViewModel(context: context))
    }
    
    var body: some View {
        TabView {
            HomeWorkoutView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            PlansView(vm: vm)
                .tabItem {
                    Label("Plans", systemImage: "creditcard")
                }
            
            AttendanceView(vm: vm)
                .tabItem {
                    Label("Attendance", systemImage: "checkmark.circle")
                }
            
            ReportView(vm: vm)
                .tabItem {
                    Label("Report", systemImage: "doc.text")
                }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

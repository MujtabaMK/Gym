//
//  GymViewModel.swift
//  Gym
//
//  Created by Mujtaba Khan on 19/09/25.
//

import Foundation
import CoreData

class GymViewModel: ObservableObject {
    let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
    
    // MARK: - Memberships
    func setMembership(plan: MembershipPlanEntity) {
        // Deactivate others
        let fetch: NSFetchRequest<MembershipPlanEntity> = MembershipPlanEntity.fetchRequest()
        if let memberships = try? viewContext.fetch(fetch) {
            memberships.forEach { $0.isActive = false }
        }
        
        plan.isActive = true
        save()
    }
    
    func activeMembership() -> MembershipPlanEntity? {
        let fetch: NSFetchRequest<MembershipPlanEntity> = MembershipPlanEntity.fetchRequest()
        fetch.predicate = NSPredicate(format: "isActive == true")
        return try? viewContext.fetch(fetch).first
    }
    
    // MARK: - Attendance
    func markAttendance() {
        markAttendance(for: Date()) // Default to today
    }
    
    func markAttendance(for date: Date) {
        let selectedDay = Calendar.current.startOfDay(for: date)
        
        // Prevent duplicate attendance for the same day
        let fetch: NSFetchRequest<AttendanceEntity> = AttendanceEntity.fetchRequest()
        fetch.predicate = NSPredicate(format: "date == %@", selectedDay as CVarArg)
        
        if let results = try? viewContext.fetch(fetch), results.isEmpty {
            let record = AttendanceEntity(context: viewContext)
            record.date = selectedDay
            save()
        }
    }
    
    func deleteAttendance(record: AttendanceEntity) {
        viewContext.delete(record)
        save()
    }

    
    // MARK: - Save
    func save() {
        do {
            try viewContext.save()
        } catch {
            print("❌ Error saving: \(error.localizedDescription)")
        }
    }
}


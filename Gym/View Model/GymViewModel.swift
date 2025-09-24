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
        // Normalize to startOfDay when saving
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

    func save() {
        do {
            try viewContext.save()
        } catch {
            print("❌ Error saving: \(error.localizedDescription)")
        }
    }
}

// MARK: - Present / Absent (robust)
extension GymViewModel {

    /// Inclusive membership end date: start + months - 1 day.
    /// If durationInMonths <= 0 we treat it as open-ended (returns nil).
    func membershipEndDate(for plan: MembershipPlanEntity) -> Date? {
        guard let start = plan.startDate else { return nil }
        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: start)
        let months = Int(plan.durationInMonths)

        guard months > 0, let after = calendar.date(byAdding: .month, value: months, to: startDay) else {
            return nil // open-ended
        }
        // Inclusive end is (start + months) - 1 day
        return calendar.date(byAdding: .day, value: -1, to: after)
    }

    /// Returns a Set of normalized attendance dates (startOfDay) within the membership period (capped to today).
    func attendanceDatesSet(for plan: MembershipPlanEntity) -> Set<Date> {
        guard let start = plan.startDate else { return [] }
        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: start)

        // end is either membership end (inclusive) or today (whichever is earlier)
        let rawMembershipEnd = membershipEndDate(for: plan) ?? Date()
        let endDay = calendar.startOfDay(for: min(rawMembershipEnd, Date()))

        if startDay > endDay { return [] }

        let fetch: NSFetchRequest<AttendanceEntity> = AttendanceEntity.fetchRequest()
        fetch.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDay as CVarArg, endDay as CVarArg)

        do {
            let results = try viewContext.fetch(fetch)
            // normalize to startOfDay to deduplicate
            let normalized = results.compactMap { $0.date }.map { calendar.startOfDay(for: $0) }
            return Set(normalized)
        } catch {
            print("Error fetching attendance: \(error)")
            return []
        }
    }

    func presentCount(for plan: MembershipPlanEntity) -> Int {
        return attendanceDatesSet(for: plan).count
    }

    /// Absent days = total days in membership period (inclusive) up to today (or end) minus present days.
    func absentDays(for plan: MembershipPlanEntity) -> Int {
        guard let start = plan.startDate else { return 0 }
        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: start)

        let rawMembershipEnd = membershipEndDate(for: plan) ?? Date()
        let endDay = calendar.startOfDay(for: min(rawMembershipEnd, Date()))

        if startDay > endDay { return 0 }

        let dayComponents = calendar.dateComponents([.day], from: startDay, to: endDay)
        let totalDaysInclusive = (dayComponents.day ?? 0) + 1 // include start day

        let present = presentCount(for: plan)
        let absent = totalDaysInclusive - present
        return max(absent, 0)
    }

    /// Optional helper: remove duplicate attendance rows (keeps one per day)
    func cleanDuplicateAttendance() {
        let fetch: NSFetchRequest<AttendanceEntity> = AttendanceEntity.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \AttendanceEntity.date, ascending: true)]

        do {
            let records = try viewContext.fetch(fetch)
            let calendar = Calendar.current
            var seen = Set<Date>()

            for r in records {
                guard let d = r.date else {
                    viewContext.delete(r) // remove bad rows without date
                    continue
                }
                let day = calendar.startOfDay(for: d)
                if seen.contains(day) {
                    // duplicate day — delete this extra record
                    viewContext.delete(r)
                } else {
                    seen.insert(day)
                }
            }
            try viewContext.save()
        } catch {
            print("Error cleaning duplicates: \(error)")
        }
    }
}

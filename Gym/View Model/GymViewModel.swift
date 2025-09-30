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
    func membershipEndDate(for plan: MembershipPlanEntity) -> Date? {
        guard let start = plan.startDate else { return nil }
        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: start)
        let months = Int(plan.durationInMonths)

        guard months > 0, let after = calendar.date(byAdding: .month, value: months, to: startDay) else {
            return nil
        }
        return calendar.date(byAdding: .day, value: -1, to: after)
    }

    /// Returns a Set of attendance dates within membership period
    func attendanceDatesSet(for plan: MembershipPlanEntity) -> Set<Date> {
        guard let start = plan.startDate else { return [] }
        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: start)

        let rawMembershipEnd = membershipEndDate(for: plan) ?? Date()
        let endDay = calendar.startOfDay(for: min(rawMembershipEnd, Date()))

        if startDay > endDay { return [] }

        let fetch: NSFetchRequest<AttendanceEntity> = AttendanceEntity.fetchRequest()
        fetch.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDay as CVarArg, endDay as CVarArg)

        do {
            let results = try viewContext.fetch(fetch)
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

    func absentDays(for plan: MembershipPlanEntity) -> Int {
        guard let start = plan.startDate else { return 0 }
        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: start)

        let rawMembershipEnd = membershipEndDate(for: plan) ?? Date()
        let endDay = calendar.startOfDay(for: min(rawMembershipEnd, Date()))

        if startDay > endDay { return 0 }

        let dayComponents = calendar.dateComponents([.day], from: startDay, to: endDay)
        let totalDaysInclusive = (dayComponents.day ?? 0) + 1

        let present = presentCount(for: plan)
        let absent = totalDaysInclusive - present
        return max(absent, 0)
    }

    /// ✅ Return all absent dates
    func absentDates(for plan: MembershipPlanEntity) -> [Date] {
        guard let start = plan.startDate else { return [] }
        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: start)

        let rawMembershipEnd = membershipEndDate(for: plan) ?? Date()
        let endDay = calendar.startOfDay(for: min(rawMembershipEnd, Date()))

        if startDay > endDay { return [] }

        var allDays: [Date] = []
        var day = startDay
        while day <= endDay {
            allDays.append(day)
            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = next
        }

        let present = attendanceDatesSet(for: plan)
        let absents = allDays.filter { !present.contains($0) }
        return absents
    }
}

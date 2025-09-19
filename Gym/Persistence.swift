//
//  Persistence.swift
//  Gym
//
//  Created by Mujtaba Khan on 19/09/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    // MARK: - Preview
    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        // Seed preview-only membership plans
        let plans = [
            ("1 Month", 1, 2000.0),
            ("3 Months", 3, 4000.0),
            ("6 Months", 6, 6000.0),
            ("1 Year", 12, 12000.0)
        ]

        for (name, duration, price) in plans {
            let plan = MembershipPlanEntity(context: viewContext)
            plan.name = name
            plan.durationInMonths = Int16(duration)
            plan.price = price
            plan.isActive = false
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    // MARK: - Core Data Stack
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Gym") // must match your .xcdatamodeld filename

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true

        // ✅ Seed default membership plans if none exist
        seedPlansIfNeeded()
    }

    // MARK: - Seeding Default Data
    private func seedPlansIfNeeded() {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<MembershipPlanEntity> = MembershipPlanEntity.fetchRequest()

        do {
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                let plans = [
                    ("1 Month", 1, 2000.0),
                    ("3 Months", 3, 4000.0),
                    ("6 Months", 6, 6000.0),
                    ("1 Year", 12, 12000.0)
                ]

                for (name, duration, price) in plans {
                    let plan = MembershipPlanEntity(context: context)
                    plan.name = name
                    plan.durationInMonths = Int16(duration)
                    plan.price = price
                    plan.isActive = false
                }

                try context.save()
                print("✅ Default membership plans seeded")
            }
        } catch {
            print("❌ Failed to seed membership plans: \(error.localizedDescription)")
        }
    }
}

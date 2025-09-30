//
//  ReportView.swift
//  Gym
//
//  Created by Mujtaba Khan on 19/09/25.
//

import SwiftUI
import CoreData

struct ReportView: View {
    @ObservedObject var vm: GymViewModel
    
    @FetchRequest(
        sortDescriptors: [],
        predicate: NSPredicate(format: "isActive == true"),
        animation: .default
    ) private var activePlans: FetchedResults<MembershipPlanEntity>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AttendanceEntity.date, ascending: true)],
        animation: .default
    ) private var attendance: FetchedResults<AttendanceEntity>
    
    var body: some View {
        NavigationView {
            List {
                if let plan = activePlans.first {
                    
                    // Present Count
                    Section(header: Text("Present")) {
                        HStack {
                            Text("Present:")
                            Spacer()
                            Text("\(vm.presentCount(for: plan))")
                        }
                    }
                    
                    // Absent Count
                    Section(header: Text("Absent")) {
                        HStack {
                            Text("Total Absent:")
                            Spacer()
                            Text("\(vm.absentDays(for: plan))")
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Membership Details
                    Section(header: Text("Membership")) {
                        Text("Plan: \(plan.name ?? "")")
                        Text("Duration: \(plan.durationInMonths) months")
                        Text("Price: \(Int(plan.price))")
                        if let startDate = plan.startDate {
                            Text("Start Date: \(startDate, style: .date)")
                        }
                    }
                    
                    // Attendance Records
                    Section(header: Text("Present Dates")) {
                        if attendance.isEmpty {
                            Text("No attendance records yet")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(attendance) { record in
                                if let date = record.date {
                                    Text(date, style: .date)
                                }
                            }
                            .onDelete { offsets in
                                offsets.forEach { index in
                                    let record = attendance[index]
                                    vm.deleteAttendance(record: record)
                                }
                            }
                        }
                    }
                    
                    // Absent Dates at Bottom
                    Section(header: Text("Absent Dates")) {
                        let absents = vm.absentDates(for: plan)
                        if absents.isEmpty {
                            Text("No absent days 🎉")
                                .foregroundColor(.green)
                        } else {
                            ForEach(absents, id: \.self) { date in
                                Text(date, style: .date)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                } else {
                    Section(header: Text("Membership")) {
                        Text("No active plan selected")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Report")
            .toolbar { EditButton() }
        }
    }
}

//#Preview {
//    ReportView()
//}

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
                    Section(header: Text("Present")) {
                        HStack {
                            Text("Present:")
                            Spacer()
                            Text("\(vm.presentCount(for: plan))")
                        }
                    }

                    Section(header: Text("Absent")) {
                        HStack {
                            Text("Absent:")
                            Spacer()
                            Text("\(vm.absentDays(for: plan))")
                                .foregroundColor(.red)
                        }
                    }
                    
                    // ✅ Membership Info
                    Section(header: Text("Membership")) {
                        Text("Plan: \(plan.name ?? "")")
                        Text("Duration: \(plan.durationInMonths) months")
                        Text("Price: \(Int(plan.price))")
                        if let startDate = plan.startDate {
                            Text("Start Date: \(startDate, style: .date)")
                        }
                    }
                } else {
                    Section(header: Text("Membership")) {
                        Text("No active plan selected")
                            .foregroundColor(.gray)
                    }
                }
                
                // ✅ Attendance Records
                Section(header: Text("Attendance")) {
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
            }
            .navigationTitle("Report")
            .toolbar { EditButton() }
        }
    }
}


//#Preview {
//    ReportView()
//}

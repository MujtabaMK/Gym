//
//  AttendanceView.swift
//  Gym
//
//  Created by Mujtaba Khan on 19/09/25.
//

import SwiftUI

struct AttendanceView: View {
    @ObservedObject var vm: GymViewModel
    @State private var selectedDate = Date()
    var body: some View {
        VStack(spacing: 30) {
            if let plan = vm.activeMembership() {
                Text("Current Plan: \(plan.name ?? "")")
                    .font(.headline)
                Divider()
                    .padding(.vertical)
                VStack(spacing: 15) {
                    DatePicker( "Select a Date", selection: $selectedDate, displayedComponents: [.date] ) .datePickerStyle(.graphical)
                    Button(action: {
                        vm.markAttendance(for: selectedDate)
                    }) {
                        Text("Mark Attendance for Selected Date")
                            .font(.title3)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
            } else {
                Text("Select a membership plan first")
                    .foregroundColor(.red)
            }
        } .padding()
    }
}

//#Preview {
//    AttendanceView()
//}

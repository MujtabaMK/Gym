//
//  PlansView.swift
//  Gym
//
//  Created by Mujtaba Khan on 19/09/25.
//

import SwiftUI
import CoreData

struct PlansView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var vm: GymViewModel
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MembershipPlanEntity.name, ascending: true)],
        animation: .default
    )
    private var plans: FetchedResults<MembershipPlanEntity>
    
    @State private var selectedStartDate = Date()
    @State private var selectedPlan: MembershipPlanEntity?
    @State private var showDatePicker = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(plans) { plan in
                    Button(action: {
                        selectedPlan = plan
                        selectedStartDate = Date()
                        showDatePicker = true
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(plan.name ?? "")
                                    .font(.headline)
                                Text("\(plan.durationInMonths) months")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("\(Int(plan.price))")
                                .foregroundColor(plan.isActive ? .blue : .gray)
                                .bold()
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Membership Plans")
            .sheet(isPresented: $showDatePicker) {
                VStack(spacing: 20) {
                    Text("Select Start Date for \(selectedPlan?.name ?? "")")
                        .font(.headline)
                    
                    DatePicker(
                        "Start Date",
                        selection: $selectedStartDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    
                    Button("Confirm") {
                        if let plan = selectedPlan {
                            plan.startDate = selectedStartDate
                            vm.setMembership(plan: plan)
                            vm.save()
                        }
                        showDatePicker = false
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding()
            }
        }
    }
}

//#Preview {
//    PlansView()
//}

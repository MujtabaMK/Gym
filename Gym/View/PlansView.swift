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
    @FetchRequest( sortDescriptors: [NSSortDescriptor(keyPath: \MembershipPlanEntity.name, ascending: true)], animation: .default )
    private var plans: FetchedResults<MembershipPlanEntity>
    var body: some View {
        NavigationView {
            List {
                ForEach(plans) {
                    plan in
                    Button(action: {
                        vm.setMembership(plan: plan)
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
        }
    }
}
//#Preview {
//    PlansView()
//}

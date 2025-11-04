//
//  HomeWorkoutView.swift
//  Gym
//
//  Created by Mujtaba Khan on 04/11/25.
//

import SwiftUI

func generateDailyWorkout() -> [Exercise] {
    var allExercises = homeWorkoutData.flatMap { $0.exercises }
    allExercises.shuffle()
    return Array(allExercises.prefix(4))
}

struct HomeWorkoutView: View {
    @State private var dailyWorkout: [Exercise] = generateDailyWorkout()
    @State private var selectedExercise: Exercise?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Daily Plan
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🔥 Daily Workout Plan")
                            .font(.title2).bold()
                            .padding(.horizontal)

                        ForEach(dailyWorkout) { exercise in
                            Button(action: { selectedExercise = exercise }) {
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(.red)
                                    VStack(alignment: .leading) {
                                        Text(exercise.name).font(.headline)
                                        Text(exercise.duration)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        }

                        Button("🔁 Refresh Plan") {
                            dailyWorkout = generateDailyWorkout()
                        }
                        .font(.callout)
                        .padding(.horizontal)
                    }

                    Divider().padding(.horizontal)

                    // Categories
                    Text("💪 Workout Categories")
                        .font(.title2).bold()
                        .padding(.horizontal)

                    ForEach(homeWorkoutData) { category in
                        NavigationLink(destination: ExerciseListView(category: category)) {
                            HStack {
                                Image(systemName: category.image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .padding()
                                    .background(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .cornerRadius(16)
                                    .foregroundColor(.white)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(category.name)
                                        .font(.title3)
                                        .bold()
                                    Text("\(category.exercises.count) Exercises")
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                            .shadow(radius: 1)
                        }
                    }
                }
                .padding(.top)
            }
            .navigationTitle("🏠 Home Workouts")
            .sheet(item: $selectedExercise) { exercise in
                ExercisePlayerView(exercise: exercise)
            }
        }
    }
}

struct ExerciseListView: View {
    let category: WorkoutCategory
    @State private var selectedExercise: Exercise?

    var body: some View {
        List {
            ForEach(category.exercises) { exercise in
                Button(action: { selectedExercise = exercise }) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 26))
                        VStack(alignment: .leading) {
                            Text(exercise.name).font(.headline)
                            Text(exercise.duration)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .navigationTitle(category.name)
        .sheet(item: $selectedExercise) { exercise in
            ExercisePlayerView(exercise: exercise)
        }
    }
}

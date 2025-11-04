//
//  ExerciseModel.swift
//  Gym
//
//  Created by Mujtaba Khan on 04/11/25.
//

import Foundation

struct Exercise: Identifiable {
    let id = UUID()
    let name: String
    let duration: String
    let videoURL: String
    let type: String
}

struct WorkoutCategory: Identifiable {
    let id = UUID()
    let name: String
    let image: String
    let exercises: [Exercise]
}

// MARK: - Sample Data
let homeWorkoutData: [WorkoutCategory] = [
    WorkoutCategory(
        name: "Full Body",
        image: "figure.walk",
        exercises: [
            Exercise(name: "Jumping Jack",
                     duration: "30 Sec",
                     videoURL: "https://www.youtube.com/watch?v=c4DAnQ6DtF8",
                     type: "Full Body"),
            Exercise(name: "Push Ups",
                     duration: "20 reps",
                     videoURL: "https://www.youtube.com/watch?v=IODxDxX7oi4",
                     type: "Full Body"),
            Exercise(name: "Squat",
                     duration: "20 Sec",
                     videoURL: "https://www.youtube.com/watch?v=xqvCmoLULNY",
                     type: "Full Body")
        ]
    ),
    WorkoutCategory(
        name: "Abs Workout",
        image: "figure.core.training",
        exercises: [
            Exercise(name: "Plank",
                     duration: "60 sec",
                     videoURL: "https://www.youtube.com/watch?v=pSHjTRCQxIw",
                     type: "Abs"),
            Exercise(name: "Crunches",
                     duration: "25 reps",
                     videoURL: "https://www.youtube.com/watch?v=Xyd_fa5zoEU",
                     type: "Abs"),
            Exercise(name: "Leg Raise",
                     duration: "40 Sec",
                     videoURL: "https://www.youtube.com/watch?v=Wp4BlxcFTkE",
                     type: "Abs")
        ]
    ),
    WorkoutCategory(
        name: "Yoga & Stretch",
        image: "figure.mind.and.body",
        exercises: [
            Exercise(name: "Sun Salutation",
                     duration: "7 min",
                     videoURL: "https://www.youtube.com/watch?v=73sjOu0g58M",
                     type: "Yoga"),
            Exercise(name: "Cobra Pose",
                     duration: "1 min",
                     videoURL: "https://www.youtube.com/watch?v=XU0wJ0OTopU",
                     type: "Yoga"),
            Exercise(name: "Child Pose",
                     duration: "1 min",
                     videoURL: "https://www.youtube.com/watch?v=kH12QrSGedM",
                     type: "Yoga")
        ]
    )
]

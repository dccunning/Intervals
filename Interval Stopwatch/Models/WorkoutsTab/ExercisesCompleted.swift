//
//  ExercisesCompleted.swift
//  Interval Stopwatch
//
//  Created by Dimitri Cunning on 18/07/2024.
//

import SwiftUI

class ExercisesCompleted: ObservableObject, Identifiable {
    @Published var id: Int
    @Published var markedForDate: Date
    @Published var gymWeightUnits: Int
    @Published var reps: Int
    @Published var sets: Int
    @Published var durationHours: Int
    @Published var durationMinutes: Int
    @Published var durationSeconds: Int

    init(id: Int, markedForDate: Date, gymWeightUnits: Int, reps: Int, sets: Int, durationHours: Int = 0, durationMinutes: Int, durationSeconds: Int) {
        self.id = id
        self.markedForDate = markedForDate
        self.gymWeightUnits = gymWeightUnits
        self.reps = reps
        self.sets = sets
        self.durationHours = durationHours
        self.durationMinutes = durationMinutes
        self.durationSeconds = durationSeconds
    }
    
}

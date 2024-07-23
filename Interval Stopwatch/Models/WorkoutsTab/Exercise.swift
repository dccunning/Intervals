//
//  Exercise.swift
//  Interval Stopwatch
//
//  Created by Dimitri Cunning on 07/07/2024.
//

import SwiftUI

class Exercise: ObservableObject, Identifiable, Hashable {
    @Published var id: Int
    @Published var name: String
    @Published var gymWeightUnits: Int
    @Published var reps: Int
    @Published var sets: Int
    @Published var durationHours: Int
    @Published var durationMinutes: Int
    @Published var durationSeconds: Int
    @Published var color: Color
    @Published var notes: String
    
    init(id: Int, name: String, gymWeightUnits: Int = 0, reps: Int = 0, sets: Int = 0, durationHours: Int = 0, durationMinutes: Int = 0, durationSeconds: Int = 0, color: String = "", notes: String = "") {
        self.id = id
        self.name = name
        self.gymWeightUnits = gymWeightUnits
        self.reps = reps
        self.sets = sets
        self.durationHours = durationHours
        self.durationMinutes = durationMinutes
        self.durationSeconds = durationSeconds
        self.color = ColorSelection.fromString(color)?.color ?? .clear
        self.notes = notes
    }
    
    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.gymWeightUnits == rhs.gymWeightUnits &&
               lhs.reps == rhs.reps &&
               lhs.sets == rhs.sets &&
               lhs.durationHours == rhs.durationHours &&
               lhs.durationMinutes == rhs.durationMinutes &&
               lhs.durationSeconds == rhs.durationSeconds &&
               lhs.color == rhs.color &&
               lhs.notes == rhs.notes
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(gymWeightUnits)
        hasher.combine(reps)
        hasher.combine(sets)
        hasher.combine(durationHours)
        hasher.combine(durationMinutes)
        hasher.combine(durationSeconds)
        hasher.combine(color)
        hasher.combine(notes)
    }
}

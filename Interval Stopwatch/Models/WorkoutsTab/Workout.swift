//
//  Workouts.swift
//  Interval Stopwatch
//
//  Created by Dimitri Cunning on 04/04/2024.
//

import SwiftUI

class Workout: ObservableObject, Identifiable, Hashable {
    @Published var id: Int
    @Published var name: String
    @Published var durationMinutes: Int
    @Published var color: String
    @Published var chunkSize: Int
    @Published var lastCompletedTimestamp: Date?
    
    init(id: Int, name: String, durationMinutes: Int, color: String, chunkSize: Int, lastCompletedTimestamp: Date?) {
        self.id = id
        self.name = name
        self.durationMinutes = durationMinutes
        self.color = color
        self.chunkSize = chunkSize
        self.lastCompletedTimestamp = lastCompletedTimestamp
    }
    
    static func == (lhs: Workout, rhs: Workout) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.durationMinutes == rhs.durationMinutes &&
               lhs.color == rhs.color &&
               lhs.chunkSize == rhs.chunkSize &&
               lhs.lastCompletedTimestamp == rhs.lastCompletedTimestamp
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(durationMinutes)
        hasher.combine(color)
        hasher.combine(chunkSize)
        hasher.combine(lastCompletedTimestamp)
    }
}

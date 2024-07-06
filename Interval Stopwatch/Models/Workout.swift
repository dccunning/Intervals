//
//  Workouts.swift
//  Interval Stopwatch
//
//  Created by Dimitri Cunning on 04/04/2024.
//

import SwiftUI

class Workout: ObservableObject {
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
}

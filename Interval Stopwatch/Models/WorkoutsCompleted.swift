//
//  WorkoutsCompleted.swift
//  Interval Stopwatch
//
//  Created by Dimitri Cunning on 15/04/2024.
//

import SwiftUI

class WorkoutsCompleted: ObservableObject {
    @Published var id: Int
    @Published var workoutId: Int
    @Published var markedForDate: Date
    @Published var completed: Bool
    @Published var updatedTimestamp: Date
    
    // Not in table
    @Published var color: String?
    @Published var chunkSize: Int?
    @Published var indexDate: Int?
    @Published var currentDatetime: Date?
    
    init(id: Int, workoutId: Int, markedForDate: Date, completed: Bool, updatedTimestamp: Date, color: String? = nil, chunkSize: Int? = nil,
         indexDate: Int? = nil, currentDatetime: Date? = nil) {
        self.id = id
        self.workoutId = workoutId
        self.markedForDate = markedForDate
        self.completed = completed
        self.updatedTimestamp = updatedTimestamp
        self.color = color
        self.chunkSize = chunkSize
        self.indexDate = indexDate
        self.currentDatetime = currentDatetime
    }
    
    func getColor() -> Color? {
        if let colorString = color, let colorSelection = ColorSelection.fromString(colorString) {
            return colorSelection.color
        } else {
            return nil
        }
    }
}

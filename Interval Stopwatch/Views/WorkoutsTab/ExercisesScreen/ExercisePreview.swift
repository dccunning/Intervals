//
//  ExercisePreview.swift
//  Interval Stopwatch
//
//  Created by Dimitri Cunning on 07/07/2024.
//

import SwiftUI

struct ExercisePreview: View {
    @ObservedObject var settings: Settings
    @ObservedObject var exercise: Exercise
    
    init(settings: Settings, exercise: Exercise) {
        self.exercise = exercise
        self.settings = settings
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            HStack (spacing: 4) {
                Text("\(self.exercise.name) ")
                if self.exercise.showCheckMarkVisual {
                    Image(systemName: "checkmark").foregroundColor(.green)
                }
                Spacer()
                
                if self.exercise.gymWeightUnits > 0 {
                    let weight: Double = Double(self.exercise.gymWeightUnits) * settings.measurementSystem.multiplier
                    let shortForm: String = settings.measurementSystem.shortForm
                    let specifier: String = settings.measurementSystem.specifier
                    Text(weight == floor(weight) ? "\(Int(weight)) \(shortForm)" : "\(weight, specifier: specifier) \(shortForm)").foregroundColor(.gray)
                    Spacer().frame(width: 6)
                }
                
                let durationExists: Bool = self.exercise.durationHours > 0 || self.exercise.durationMinutes > 0 || self.exercise.durationSeconds > 0
                
                if durationExists {
                    let hours: String = self.exercise.durationHours != 0 ? "\(self.exercise.durationHours)h" : ""
                    let minutes: String = self.exercise.durationMinutes != 0 ? "\(self.exercise.durationMinutes)m" : ""
                    let seconds: String = self.exercise.durationSeconds != 0 ? "\(self.exercise.durationSeconds)s" : ""
                    
                    if (self.exercise.reps > 0 || self.exercise.sets > 0) {
                        Text("\(hours) \(minutes) \(seconds)")
                        Text("x")
                    } else {
                        Text("\(hours) \(minutes) \(seconds)")
                    }
                }
                if (self.exercise.reps > 0) {
                    if (self.exercise.sets > 0) {
                        Text("\(self.exercise.reps)")
                        Text("x")
                    } else {
                        Text("\(self.exercise.reps)")
                    }
                }
                if (self.exercise.sets > 0) {
                    Text("\(self.exercise.sets)")
                }

            }
            if (self.exercise.notes.count > 0) {
                Text(self.exercise.notes).font(.system(size: 10)).foregroundColor(.gray)
            }
        }
        .swipeActions (edge: .leading) {
            let checkMarkDisplayed: Bool = self.exercise.showCheckMarkVisual
            let icon: String = checkMarkDisplayed ? "xmark" : "checkmark"
            let tint: Color = checkMarkDisplayed ? Color.gray : Color(red: 0, green: 0.5, blue: 0)
            Button(action: {
                self.exercise.showCheckMarkVisual.toggle()
                DataBase().updateExerciseCheckMarkVisual(
                    exerciseId: self.exercise.id,
                    newValue: self.exercise.showCheckMarkVisual
                )
            }) {
                Image(systemName: icon)
            }.tint(tint)
        }
    }
}

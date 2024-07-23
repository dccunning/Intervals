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
    @Binding var currentSelectedDate: Date
    @State private var showCheckMarkVisual: Bool = false
    
    init(settings: Settings, exercise: Exercise, currentSelectedDate: Binding<Date>) {
        self.exercise = exercise
        self.settings = settings
        self._currentSelectedDate = currentSelectedDate
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            HStack (spacing: 4) {
                Text("\(self.exercise.name) ")
                if showCheckMarkVisual {
                    Image(systemName: "checkmark").foregroundColor(.green)
                }
                Spacer()
                
                if self.exercise.gymWeightUnits > 0 {
                    let weight: Double = Double(self.exercise.gymWeightUnits) * settings.measurementSystem.multiplier
                    let shortForm: String = settings.measurementSystem.shortForm
                    Text("\(String(format: "%g", weight)) \(shortForm)").foregroundColor(.gray)
                    Spacer().frame(width: 6)
                }
                
                let durationExists: Bool = self.exercise.durationHours > 0 || self.exercise.durationMinutes > 0 || self.exercise.durationSeconds > 0
                
                if durationExists {
                    Text(formatTime(hour: exercise.durationHours, minute: exercise.durationMinutes, second: exercise.durationSeconds))
                    if (self.exercise.reps > 0 || self.exercise.sets > 0) {
                        Text("x")
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
            let checkMarkDisplayed: Bool = showCheckMarkVisual
            let icon: String = checkMarkDisplayed ? "xmark" : "checkmark"
            let tint: Color = checkMarkDisplayed ? Color.gray : Color(red: 0, green: 0.5, blue: 0)
            Button(action: {
                if DataBase().insertOrToggleExercisesCompletedRow(
                    exerciseId: self.exercise.id,
                    exerciseName: self.exercise.name,
                    markedForDate: self.currentSelectedDate,
                    gymWeightUnits: self.exercise.gymWeightUnits,
                    reps: self.exercise.reps,
                    sets: self.exercise.sets,
                    durationHours: self.exercise.durationHours,
                    durationMinutes: self.exercise.durationMinutes,
                    durationSeconds: self.exercise.durationSeconds
                ) {
                    updateCheckMarkVisual()
                }
            }) {
                Image(systemName: icon)
            }.tint(tint)
        }
        .onAppear {
            updateCheckMarkVisual()
        }
    }
    
    private func updateCheckMarkVisual() {
        showCheckMarkVisual = DataBase().isExerciseCompleteOnDate(exerciseId: exercise.id, date: currentSelectedDate)
    }
    
    private func formatTime(hour: Int, minute: Int, second: Int) -> String {
        if hour > 0 {
            return String(format: "%d:%02d:%02d", hour, minute, second)
        } else if minute > 0 {
            return String(format: "%d:%02d", minute, second)
        } else {
            return String(format: "0:%02d", second)
        }
    }
}

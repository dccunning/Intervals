//  Created by Dimitri Cunning on 03/07/2024.
//

import SwiftUI
import SQLite3

struct ExerciseFormView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var settings: Settings
    @Binding var isPresented: Bool
    @Binding var workoutId: Int
    @Binding var exercises: [Exercise]
    @State var editForExerciseId: Int?
    @State private var name: String = ""
    @State private var sets: Int = 0
    @State private var reps: Int = 0
    @State private var durationSeconds: Int = 0
    @State private var durationMinutes: Int = 0
    @State private var durationHours: Int = 0
    @State private var gymWeightUnits: Int = 0
    @State private var selectedColor: ColorSelection = ColorSelection.clear
    @State private var notes: String = ""
    @State private var currentName: String?
    @State private var currentSets: Int?
    @State private var currentReps: Int?
    @State private var currentDurationSeconds: Int?
    @State private var currentDurationMinutes: Int?
    @State private var currentDurationHours: Int?
    @State private var currentGymWeightUnits: Int?
    @State private var currentSelectedColor: ColorSelection?
    @State private var currentNotes: String?
    var changedASingleInput: Bool {
        currentName != name || currentSets != sets || currentReps != reps || currentDurationSeconds != durationSeconds || currentDurationMinutes != durationMinutes || currentDurationHours != durationHours || currentGymWeightUnits != gymWeightUnits || currentSelectedColor?.displayName != selectedColor.displayName || currentNotes != notes
    }
    
    @State var currentExerciseData: [[Any]]? = nil
    @State var showingDeleteConfirmation: Bool = false
    @FocusState var isName: Bool
    @FocusState var isNotes: Bool
    var formTitle: String {
        editForExerciseId != nil ? "Edit Exercise" : "Add Exercise"
    }
    var finishedButton: String {
        editForExerciseId != nil ? "Save" : "Done"
    }
    let db: DataBase = DataBase()
    
        
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Name")) {
                    TextField("Exercise name", text: $name)
                        .submitLabel(.done)
                        .focused($isName)
                        .onSubmit() {
                            isName = false
                        }
                }
                
                Section(header: Text("Measures")) {
                    Picker(selection: $gymWeightUnits, label: Text("Weight")) {
                        ForEach(0..<241) { index in
                            let weight: Double = Double(index) * settings.measurementSystem.multiplier
                            let shortForm: String = settings.measurementSystem.shortForm
                            let specifier: String = settings.measurementSystem.specifier
                            Text(weight == floor(weight) ? "\(Int(weight)) \(shortForm)" : "\(weight, specifier: specifier) \(shortForm)")
                        }
                    }
                    Picker(selection: $reps, label: Text("Reps")) {
                        ForEach(0..<101) { num in
                            Text("\(num)")
                        }
                    }
                    Picker(selection: $sets, label: Text("Sets")) {
                        ForEach(0..<101) { num in
                            Text("\(num)")
                        }
                    }
                }
                
                Section(header: Text("Duration")) {
                    HStack {
                        Text("hr")
                        Picker(selection: $durationHours, label: Text("Hours")) {
                            ForEach(0..<24) { hour in
                                Text("\(hour)")
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                                                
                        Text("min")
                        Picker(selection: $durationMinutes, label: Text("Minutes")) {
                            ForEach(0..<60) { min in
                                Text("\(min)")
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        
                        Text("sec")
                        Picker(selection: $durationSeconds, label: Text("Seconds")) {
                            ForEach(0..<60) { sec in
                                Text("\(sec)")
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                    }.frame(height: 80)
                }
                
                Section(header: Text("Colour")) {
                    Picker("Background Shade", selection: $selectedColor) {
                        ForEach([ColorSelection.clear, ColorSelection.red, ColorSelection.orange, ColorSelection.yellow, ColorSelection.green, ColorSelection.blue, ColorSelection.purple, ColorSelection.gray], id: \.self) { color in
                            Text(color.displayName).foregroundColor(color.color).tag(color)
                        }
                    }
                    .pickerStyle(DefaultPickerStyle())
                }
                
                Section(header: Text("Notes")) {
                    TextField("Notes", text: $notes)
                        .submitLabel(.done)
                        .focused($isNotes)
                        .onSubmit() {
                            isNotes = false
                        }
                }
                
                // Delete button: only if editing
                if let exerciseId = editForExerciseId {
                    Section {
                        Button(action: {
                            showingDeleteConfirmation = true
                        }) {
                            Text("Delete")
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }.confirmationDialog("Are you sure you want to delete this exercise?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
                            Button("Delete", role: .destructive) {
                                let success = db.deleteExercise(exerciseId: exerciseId)
                                if success {
                                    self.exercises = db.fetchExerciseTableRows(workoutId: workoutId)
                                    showingDeleteConfirmation = false
                                    isPresented = false
                                }
                            }
                            Button("Cancel", role: .cancel) {
                                showingDeleteConfirmation = false
                            }
                        }
                    }
                }
            }
            .navigationBarItems(
                leading:
                    Button("Cancel") {
                        isPresented = false
                    },
                trailing:
                    Button(finishedButton) {
                        if name.count > 0 {
                            
                            db.createExerciseTable()
                            if let exerciseId = editForExerciseId {
                                let success = db.updateExercise(exerciseId: exerciseId, workoutId: workoutId, name: name, gymWeightUnits: gymWeightUnits, reps: reps, sets: sets, durationHours: durationHours, durationMinutes: durationMinutes, durationSeconds: durationSeconds, color: selectedColor.displayName, notes: notes)
                                if success {
                                    isPresented = false
                                    self.exercises = db.fetchExerciseTableRows(workoutId: workoutId)
                                }
                                
                            }
                            else if db.insertExerciseTableRow(
                                workoutId: workoutId, name: name, gymWeightUnits: gymWeightUnits, reps: reps, sets: sets, durationHours: durationHours, durationMinutes: durationMinutes, durationSeconds: durationSeconds, color: selectedColor.displayName, notes: notes
                            ) {
                                isPresented = false
                                self.exercises = db.fetchExerciseTableRows(workoutId: workoutId)
                            }
                        }
                    }.disabled(name.count == 0 || (editForExerciseId != nil && !changedASingleInput))
            )
            .navigationBarTitle(
                formTitle, displayMode: .inline
            )
        }
        .preferredColorScheme(colorScheme)
        .onAppear(perform: setDefaultValues)
    }

    private func setDefaultValues() {
        if let exerciseId = editForExerciseId {
            currentExerciseData = db.selectQuery("select name, gymWeightUnits, reps, sets, durationHours, durationMinutes, durationSeconds, color, notes from Exercises where id = \(exerciseId)")
            
            if let dataArray = currentExerciseData,
               let firstRow = dataArray.first {
                name = firstRow[0] as? String ?? name
                gymWeightUnits = firstRow[1] as? Int ?? gymWeightUnits
                reps = firstRow[2] as? Int ?? reps
                sets = firstRow[3] as? Int ?? sets
                durationHours = firstRow[4] as? Int ?? durationHours
                durationMinutes = firstRow[5] as? Int ?? durationMinutes
                durationSeconds = firstRow[6] as? Int ?? durationSeconds
                selectedColor = ColorSelection.fromString(firstRow[7] as? String ?? selectedColor.displayName) ?? selectedColor
                notes = firstRow[8] as? String ?? notes
                
                currentName = name
                currentGymWeightUnits = gymWeightUnits
                currentReps = reps
                currentSets = sets
                currentDurationHours = durationHours
                currentDurationMinutes = durationMinutes
                currentDurationSeconds = durationSeconds
                currentSelectedColor = selectedColor
                currentNotes = notes
            }
        }
    }
    
}

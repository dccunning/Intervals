//
//  AddWorkoutItemForm.swift
//  Interval Stopwatch
//
//  Created by Dimitri Cunning on 01/04/2024.
//

import SwiftUI
import SQLite3

struct WorkoutFormView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isPresented: Bool
    @Binding var workouts: [Workout]
    @Binding var editForWorkout: Workout
    @Binding var goToAllWorkouts: Bool
    
    @State private var name: String = ""
    @State private var minutes: Int = 0
    @State private var hours: Int = 0
    @State private var selectedColor: ColorSelection = ColorSelection.red
    @State private var chunkSize: Int = 1
    @State var currentWorkoutData: [[Any]]? = nil
    @FocusState var isName: Bool
    var formTitle: String { editForWorkout.id != -1 ? "Workout Details" : "Add Workout" }
    var finishedButton: String { editForWorkout.id != -1 ? "Save" : "Done" }
    @State private var currentName: String?
    @State private var currentMinutes: Int?
    @State private var currentHours: Int?
    @State private var currentSelectedColor: ColorSelection?
    @State private var currentChunkSize: Int?
    var changedASingleInput: Bool {
        currentName != name || currentMinutes != minutes || currentHours != hours || currentSelectedColor?.displayName != selectedColor.displayName || currentChunkSize != chunkSize
    }
    @State var showingDeleteConfirmation: Bool = false
    var db: DataBase = DataBase()

    
    init(isPresented: Binding<Bool>, workouts: Binding<[Workout]>, editForWorkout: Binding<Workout>, goToAllWorkouts: Binding<Bool>) {
        self._isPresented = isPresented
        self._workouts = workouts
        self._editForWorkout = editForWorkout
        self._goToAllWorkouts = goToAllWorkouts
        if editForWorkout.id != -1 {
            self._name = State(initialValue: editForWorkout.wrappedValue.name)
            self._minutes = State(initialValue: editForWorkout.wrappedValue.durationMinutes % 60)
            self._hours = State(initialValue: editForWorkout.wrappedValue.durationMinutes / 60)
            self._chunkSize = State(initialValue: editForWorkout.wrappedValue.chunkSize)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let borderPct: CGFloat = 0.05
            let border: CGFloat = borderPct*geometry.size.width
            NavigationView {
                Form {
                    Section(header: Text("Name")) {
                        TextField("Workout name", text: $name)
                            .submitLabel(.done)
                            .focused($isName)
                            .onSubmit() {
                                isName = false
                            }
                    }
                    
                    Section(header: Text("Duration")) {
                        HStack(spacing: 0) {
                            Spacer()
                            ZStack(alignment: .leading) {
                                Picker(selection: $hours, label: Text("Hours")) {
                                    ForEach(0..<24) { hour in
                                        Text(String(format: "%2d", hour))
                                            .offset(x: -border*1, y: 0)
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(width: border*8)
                                
                                Text("hours")
                                    .bold()
                                    .offset(x: border*4, y: 0)
                            }
                            Spacer()
                            ZStack(alignment: .leading) {
                                Picker(selection: $minutes, label: Text("Minutes")) {
                                    ForEach(0..<12) { index in
                                        Text(String(format: "%2d", index * 5))
                                            .tag(index * 5)
                                            .offset(x: -border*1, y: 0)
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                            .frame(width: border*8)
                                
                                Text("min")
                                    .bold()
                                    .offset(x: border*4, y: 0)
                            }
                            
                            Spacer()
                        }.frame(height: 100)

                    }
                    
                    Section(header: Text("Colour")) {
                        Picker("Background Colour", selection: $selectedColor) {
                            ForEach(ColorSelection.allNonClearColors, id: \.self) { color in
                                Text(color.displayName).foregroundColor(color.color).tag(color)
                            }
                        }
                        .pickerStyle(DefaultPickerStyle())
                    }
                    
                    Section(header: Text("Size")) {
                        Picker(selection: $chunkSize, label: Text("Relative Workout Size")) {
                            ForEach(1..<11, id: \.self) { chunk in
                                Text("\(chunk)")
                            }
                        }
                    }
                    
                    // Delete button: only if editing
                    if editForWorkout.id != -1 {
                        Section {
                            Button(action: {
                                showingDeleteConfirmation = true
                            }) {
                                Text("Delete")
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }.confirmationDialog("Are you sure you want to delete this workout?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
                                Button("Delete", role: .destructive) {
                                    let success = db.deleteWorkout(workoutId: editForWorkout.id)
                                    if success {
                                        workouts = db.fetchWorkoutTableRows()
                                        showingDeleteConfirmation = false
                                        isPresented = false
                                        goToAllWorkouts = true
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
                            if name.count > 0 && (hours > 0 || minutes > 0) {
                                db.createWorkoutTable()
                                if editForWorkout.id != -1 {
                                    let durationMinutes = Int(hours * 60 + minutes)
                                    let success: Bool = db.updateWorkout(workoutId: editForWorkout.id, name: name, durationMinutes: durationMinutes, selectedColor: selectedColor.displayName, chunkSize: chunkSize)
                                    if success {
                                        self.editForWorkout.name = name
                                        self.editForWorkout.durationMinutes = Int(hours * 60 + minutes)
                                        self.editForWorkout.chunkSize = chunkSize
                                        self.workouts = db.fetchWorkoutTableRows()
                                        isPresented = false
                                    }
                                }
                                else if db.insertWorkoutTableRow(
                                    name: name, hours: hours, minutes: minutes,
                                    selectedColor: selectedColor, chunkSize: chunkSize
                                ) {
                                    isPresented = false
                                    self.workouts = self.db.fetchWorkoutTableRows()
                                }
                            }
                        }
                        .disabled(name.count == 0 || (hours == 0 && minutes == 0) || (editForWorkout.id != -1 && !changedASingleInput))
                    
                )
                .navigationBarTitle(
                    formTitle, displayMode: .inline
                )
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .preferredColorScheme(colorScheme)
            .onAppear(perform: setDefaultValues)
        }
    }
    
    private func setDefaultValues() {
        if isPresented && editForWorkout.id != -1 {
            currentWorkoutData = db.selectQuery("select name, durationMinutes, color, chunkSize from Workouts where id = \(editForWorkout.id)")
            
            if let dataArray = currentWorkoutData,
               let firstRow = dataArray.first {
                name = firstRow[0] as? String ?? name
                if let duration = firstRow[1] as? Int {
                    minutes = duration % 60
                    hours = duration / 60
                }
                selectedColor = ColorSelection.fromString(firstRow[2] as? String ?? selectedColor.displayName) ?? selectedColor
                chunkSize = firstRow[3] as? Int ?? chunkSize
                
                currentName = name
                currentMinutes = minutes
                currentHours = hours
                currentSelectedColor = selectedColor
                currentChunkSize = chunkSize
            }
        }
    }

}

//  Created by Dimitri Cunning on 03/07/2024.
//

import SwiftUI
import SQLite3

struct AddExerciseItemFormView: View {
    @Binding var isPresented: Bool
    @Binding var workoutId: Int
    @Binding var exercises: [Exercise]
    @State private var name: String = ""
    @State private var sets: Int = 0
    @State private var reps: Int = 0
    @State private var durationSeconds: Int = 0
    @State private var durationMinutes: Int = 0
    @State private var durationHours: Int = 0
    @State private var metricWeightKg: Int = 0
    @State private var selectedColor: ColorSelection = .clear
    @State private var notes: String = ""
    var db: DataBase = DataBase()
    
    @State private var setsString: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Name")) {
                    TextField("Exercise name", text: $name)
                }
                
                Section(header: Text("Measures")) {
                    Picker(selection: $metricWeightKg, label: Text("Weight kg")) {
                        ForEach(0..<501) { num in
                            Text("\(num)")
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
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        hideKeyboard()
                    }
                }
            }
            .navigationBarItems(
                leading:
                    Button("Cancel") {
                        isPresented = false
                    },
                trailing:
                    Button("Done") {
                        if name.count > 0 {
                            self.db.createExerciseTable()
                            if self.db.insertExerciseTableRow(
                                workoutId: workoutId, name: name, metricWeightKg: metricWeightKg, reps: reps, sets: sets, durationHours: durationHours, durationMinutes: durationMinutes, durationSeconds: durationSeconds, color: selectedColor.displayName, notes: notes
                            ) {
                                isPresented = false
                                self.exercises = self.db.fetchExerciseTableRows(workoutId: workoutId)
                            } else {
                                print("Error inserting exercise data")
                            }
                        }
                    }.disabled(name.count == 0)
            )
            .navigationBarTitle(
                "Add Exercise", displayMode: .inline
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(.dark)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


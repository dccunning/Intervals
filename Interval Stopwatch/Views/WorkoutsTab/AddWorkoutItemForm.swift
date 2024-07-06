//
//  AddWorkoutItemForm.swift
//  Interval Stopwatch
//
//  Created by Dimitri Cunning on 01/04/2024.
//

import SwiftUI
import SQLite3

struct AddWorkoutItemFormView: View {
    @Binding var isPresented: Bool
    @Binding var workouts: [Workout]
    @State private var name: String = ""
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var selectedColor: ColorSelection = .blue
    @State private var chunkSize: Int = 1
    var db: DataBase = DataBase()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Name")) {
                    TextField("Workout name", text: $name)
                }
                
                Section(header: Text("Duration")) {
                    HStack {
                        Text("Hours")
                        Picker(selection: $hours, label: Text("Hours")) {
                            ForEach(0..<24) { hour in
                                Text("\(hour)")
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        Text("Minutes")
                        Picker(selection: $minutes, label: Text("Minutes")) {
                            ForEach(0..<12) { index in
                                Text("\(index * 5)").tag(index * 5)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                    }.frame(height: 100)
                }
                
                Section(header: Text("Color")) {
                    Picker("Background Clour", selection: $selectedColor) {
                        ForEach(ColorSelection.allCases, id: \.self) { color in
                            Text(color.displayName).foregroundColor(color.color).tag(color)
                        }
                    }
                    .pickerStyle(DefaultPickerStyle())
                }
                
                Section(header: Text("Chunk Size")) {
                    Picker(selection: $chunkSize, label: Text("Relative Workout Size")) {
                        ForEach(1..<11, id: \.self) { chunk in
                            Text("\(chunk)")
                        }
                    }
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
                        if name.count > 0 && (hours > 0 || minutes > 0) {
                            self.db.createWorkoutTable()
                            if self.db.insertWorkoutTableRow(
                                name: self.name, hours: self.hours, minutes: self.minutes,
                                selectedColor: self.selectedColor, chunkSize: self.chunkSize
                            ) {
                                isPresented = false
                                self.workouts = self.db.fetchWorkoutTableRows()
                                print("Data inserted successfully")
                            } else {
                                print("Error inserting data")
                            }
                        }
                    }
                    .disabled(name.count == 0 || (hours == 0 && minutes == 0))

            )
            .navigationBarTitle(
                "Add Workout", displayMode: .inline
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(.dark)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

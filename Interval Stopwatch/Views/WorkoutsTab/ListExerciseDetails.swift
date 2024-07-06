//
//  ListExerciseDetails.swift
//  Interval Stopwatch
//
//  Created by Dimitri Cunning on 01/06/2024.
//

import SwiftUI

struct ListExerciseDetails: View {
    @Binding var workout: Workout
    @State private var exercises: [Exercise] = []
//    [
//        Exercise(id: 1, name: "21km run", metricWeightKg: 10, color: "Red", notes: "hello"),
//        Exercise(id: 2, name: "Sprints - 800m", metricWeightKg: 100, reps: 8, color: "Gray"),
//        Exercise(id: 3, name: "Track run - 5km", sets: 1, color: "Blue"),
//        Exercise(id: 4, name: "Jog", durationHours: 1, durationMinutes: 45, durationSeconds: 5),
//        Exercise(id: 5, name: "Bench press", metricWeightKg: 100, reps: 8, sets: 3, notes: "8,7,6"),
//        Exercise(id: 6, name: "Decline leg press thing thing thing", metricWeightKg: 160, reps: 12, sets: 3)
//    ]
    @State private var isEditMenuPresented: Bool = false
    
    private var formattedDate: String {
        if let lastCompletedTimestamp = workout.lastCompletedTimestamp {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE, MMMM d"
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            return dateFormatter.string(from: lastCompletedTimestamp)
        }
        return " "
    }
    
    init(workout: Binding<Workout>) {
        UITableView.appearance().backgroundColor = .black
        self._workout = workout
    }
    
    var body: some View {
        // 3. Tap item to edit (or delete)
        // 4. Edit button to edit workout details (duration, level, colour, etc)
        // 5. Swipe to toggle mark exercise as done (for the day)
        ZStack {
            VStack (alignment: .leading) {
                HStack {
                    Text("⏳ \(formattedDuration(minutes: workout.durationMinutes))").padding(.leading, 16)
                    Spacer()
                    Text("🎚️ \(workout.chunkSize)")
                    Spacer()
                    if workout.lastCompletedTimestamp != nil {
                        Text("🗓️ \(formattedDate)").padding(.trailing, 16)
                    }
                }
                
                ZStack {//
    //                Color.black.edgesIgnoringSafeArea(.all)
                    List {
                        ForEach(exercises.indices, id: \.self) { index in
                            VStack (alignment: .leading, spacing: 0) {
                                HStack (spacing: 4) {
                                    Text(self.exercises[index].name)
                                    Spacer()
                                    
                                    if self.exercises[index].metricWeightKg > 0 {
                                        Text("\(self.exercises[index].metricWeightKg)kg").foregroundColor(.gray)
                                        Spacer().frame(width: 6)
                                    }
                                    
                                    let durationExists: Bool = self.exercises[index].durationHours > 0 || self.exercises[index].durationMinutes > 0 || self.exercises[index].durationSeconds > 0
                                    
                                    if durationExists {
                                        let hours: String = self.exercises[index].durationHours != 0 ? "\(self.exercises[index].durationHours)h" : ""
                                        let minutes: String = self.exercises[index].durationMinutes != 0 ? "\(self.exercises[index].durationMinutes)m" : ""
                                        let seconds: String = self.exercises[index].durationSeconds != 0 ? "\(self.exercises[index].durationSeconds)s" : ""
                                        
                                        if (self.exercises[index].reps > 0 || self.exercises[index].sets > 0) {
                                            Text("\(hours) \(minutes) \(seconds)")
                                            Text("x")
                                        } else {
                                            Text("\(hours) \(minutes) \(seconds)")
                                        }
                                    }
                                    if (self.exercises[index].reps > 0) {
                                        if (self.exercises[index].sets > 0) {
                                            Text("\(self.exercises[index].reps)")
                                            Text("x")
                                        } else {
                                            Text("\(self.exercises[index].reps)")
                                        }
                                    }
                                    if (self.exercises[index].sets > 0) {
                                        Text("\(self.exercises[index].sets)")
                                    }

                                }
                                if (self.exercises[index].notes.count > 0) {
                                    Text(self.exercises[index].notes).font(.system(size: 10)).foregroundColor(.gray)
                                }
                            }
//                            .listRowBackground(self.exercises[index].color.opacity(0.5))
                            .id(UUID())
                        }
                        .onMove { (indices, newOffset) in
                            self.exercises.move(fromOffsets: indices, toOffset: newOffset)
                             _ = DataBase().updateExerciseIndexes(exercises: exercises)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .navigationBarTitle(workout.name)
                    .contentMargins(.vertical, 15)
                    .navigationBarItems(trailing:
                        HStack {
                            Button(action: {
                                
                                }) {
                                    Text("Edit").foregroundColor(.blue)
                            }
                            Button(action: {
                                self.isEditMenuPresented = true
                            }) {
                                Image(systemName: "plus")
                                    .foregroundColor(.blue)
                            }.sheet(isPresented: $isEditMenuPresented) {
                                AddExerciseItemFormView(isPresented: self.$isEditMenuPresented, workoutId: $workout.id, exercises: self.$exercises)
                            }
                        }
                    )
                }//
            }
        }.onAppear(perform: {
            exercises = DataBase().fetchExerciseTableRows(workoutId: workout.id)
        })
    }
    
    func formattedDuration(minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60

        if hours > 0 && remainingMinutes > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(remainingMinutes)m"
        }
    }
}


class Exercise: ObservableObject {
    @Published var id: Int
    @Published var name: String
    @Published var metricWeightKg: Int
    @Published var reps: Int
    @Published var sets: Int
    @Published var durationHours: Int
    @Published var durationMinutes: Int
    @Published var durationSeconds: Int
    @Published var color: Color
    @Published var notes: String
    
    init(id: Int, name: String, metricWeightKg: Int = 0, reps: Int = 0, sets: Int = 0, durationHours: Int = 0, durationMinutes: Int = 0, durationSeconds: Int = 0, color: String = "Clear", notes: String = "") {
        self.id = id
        self.name = name
        self.metricWeightKg = metricWeightKg
        self.reps = reps
        self.sets = sets
        self.durationHours = durationHours
        self.durationMinutes = durationMinutes
        self.durationSeconds = durationSeconds
        self.color = ColorSelection.fromString(color)?.color ?? Color.clear
        self.notes = notes
    }
}



#Preview {
    ContentView()
}

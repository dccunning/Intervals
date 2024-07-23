//
//  ListExerciseDetails.swift
//  Interval Stopwatch
//
//  Created by Dimitri Cunning on 01/06/2024.
//

import SwiftUI

struct ListExercisesView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var settings: Settings
    @Binding var workout: Workout
    @Binding var workouts: [Workout]
    @Binding var currentSelectedDate: Date
    @State private var exercises: [Exercise] = []
    @State private var addExerciseFormPresented: Bool = false
    @State private var editWorkoutFormPresented: Bool = false
    @State var isEditing: Bool = false
    @State var editForExerciseId: Int? = nil
    @State var goToAllWorkouts: Bool = false
    var db: DataBase = DataBase()
        
    private var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter.string(from: currentSelectedDate)
    }
    
    init(settings: Settings, workout: Binding<Workout>, workouts: Binding<[Workout]>, currentSelectedDate: Binding<Date>) {
        UITableView.appearance().backgroundColor = .black
        self._workout = workout
        self._workouts = workouts
        self._currentSelectedDate = currentSelectedDate
        self.settings = settings
    }
    
    var body: some View {
        ZStack {
            VStack (alignment: .leading) {
                HStack {
                    Image(systemName: "hourglass").padding(.leading, 16)
                    Text("\(formattedDuration(minutes: workout.durationMinutes))") // ⏳
                    Spacer()
                    Image(systemName: "scalemass")
                    Text("\(workout.chunkSize)") // 🎚️
                    Spacer()
                    Image(systemName: "calendar")
                    Text("\(formattedDate)").padding(.trailing, 16) // 🗓️
                }
                
                List {
                    let defaultListColor: Color = colorScheme == .dark ? Color(red: 28/255, green: 28/255, blue: 28/255) : Color.white
                    Section {
                        ForEach($exercises, id: \.self) { $exercise in
                            let rowColor: Color = $exercise.wrappedValue.color == .clear ? defaultListColor : $exercise.wrappedValue.color.opacity(0.5)
                            ExercisePreview(settings: settings, exercise: $exercise.wrappedValue, currentSelectedDate: $currentSelectedDate)
                                .listRowBackground(rowColor)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editForExerciseId = $exercise.id
                                    isEditing = true
                                }
                                .id(UUID())
                        }
                        .onMove { (indices, newOffset) in
                            self.exercises.move(fromOffsets: indices, toOffset: newOffset)
                            _ = DataBase().updateExerciseIndexes(exercises: exercises)
                        }
                    }
                    
                    let buttonTint: Color = colorScheme == .dark ? Color(red: 112/255, green: 112/255, blue: 112/255) : Color(red: 171/255, green: 171/255, blue: 171/255)
                    Section {
                        HStack (alignment: .center) {
                            Spacer()
                            Button(action: {
                                if
                                    self.db.toggleOrInsertWorkoutCompletedTableRow(
                                        workoutId: workout.id,
                                        markedForDate: currentSelectedDate,
                                        setAsComplete: true
                                    )
                                {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            presentationMode.wrappedValue.dismiss()
                                        }
                                    }
                                }
                            }) {
                                Text("Finished workout")
                                    .foregroundColor(.blue)
                                    .padding(4)
                            }
                            .buttonStyle(.bordered)
                            .tint(buttonTint)
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .listSectionSpacing(10)
                .sheet(isPresented: $isEditing) {
                    if let exerciseId = editForExerciseId {
                        ExerciseFormView(
                            settings: settings,
                            isPresented: $isEditing,
                            workoutId: $workout.id,
                            exercises: $exercises,
                            editForExerciseId: exerciseId
                        )
                        .presentationDetents([.medium])
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationBarTitle(workout.name)
                .contentMargins(.vertical, 15)
                .navigationBarItems(trailing:
                    HStack {
                        Button(action: {
                            self.editWorkoutFormPresented = true
                            }) {
                                Text("Edit").foregroundColor(.blue)
                            }.sheet(isPresented: $editWorkoutFormPresented) {
                                WorkoutFormView(
                                    isPresented: self.$editWorkoutFormPresented,
                                    workouts: self.$workouts,
                                    editForWorkout: self.$workout,
                                    goToAllWorkouts: self.$goToAllWorkouts
                                )
                                .presentationDetents([.medium])
                            }
                        Button(action: {
                            self.addExerciseFormPresented = true
                        }) {
                            Image(systemName: "plus").foregroundColor(.blue)
                        }.sheet(isPresented: $addExerciseFormPresented) {
                            ExerciseFormView(
                                settings: settings,
                                isPresented: self.$addExerciseFormPresented,
                                workoutId: $workout.id,
                                exercises: self.$exercises
                            )
                        }
                    }
                )
            }
        }
        .onAppear(perform: {
            exercises = DataBase().fetchExerciseTableRows(workoutId: workout.id)
        })
        .onChange(of: goToAllWorkouts) {
            presentationMode.wrappedValue.dismiss()
            goToAllWorkouts = false
        }
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

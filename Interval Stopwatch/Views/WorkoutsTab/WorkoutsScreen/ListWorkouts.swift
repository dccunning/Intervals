//
//  AllWorkoutsList.swift
//  Interval Stopwatch
//
//  Created by Dimitri Cunning on 31/03/2024.
//

import SQLite3
import SwiftUI

struct ListWorkoutsView: View {
    @State private var mySettings: Settings
    @State private var isAddWorkoutMenuPresented: Bool = false
    @State private var workouts: [Workout] = []
    @State private var currentSelectedDate: Date = Calendar.current.startOfDay(for: Date()).addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT(for: Date())))
    @State private var lastClickedIndex: Int = 14
    @State private var workoutsCompletedList: [WorkoutsCompleted] = []
        
    init(settings: Settings) {
        UITableView.appearance().backgroundColor = .black
        DataBase().createWorkoutTable()
        DataBase().createExerciseTable()
        DataBase().createWorkoutsCompletedTable()
        DataBase().createExercisesCompletedTable()
        self._mySettings = State(initialValue: settings)
    }
    
    @State private var dateWithTimeZone: Date = Calendar.current.startOfDay(for: Date()).addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT(for: Date())))
    
    
    var body: some View {
        let workoutPreviewHeight: CGFloat = 50
        let verticalSpacer: CGFloat = workoutPreviewHeight/5
        
        NavigationView {
            VStack {
                WorkoutLogBars(
                    workoutsCompletedList: $workoutsCompletedList,
                    currentDatetime: $dateWithTimeZone,
                    currentSelectedDate: $currentSelectedDate,
                    lastClickedIndex: $lastClickedIndex
                ).onAppear(perform: {
                    updateWorkoutsSelected()
                })
                
                Spacer().frame(height: verticalSpacer*0.8)
                    List {
                        ForEach(workouts.indices, id: \.self) { index in
                            WorkoutPreview(
                                workoutsCompletedList: self.$workoutsCompletedList,
                                currentSelectedDate: self.$currentSelectedDate,
                                workouts: self.$workouts,
                                workout: self.$workouts[index],
                                border: verticalSpacer
                            )
                            .background(
                                NavigationLink(
                                    "",
                                    destination: ListExercisesView(
                                        settings: mySettings,
                                        workout: self.$workouts[index],
                                        workouts: self.$workouts,
                                        currentSelectedDate: self.$currentSelectedDate
                                    )
                                ).opacity(0)
                            )
                            .listRowBackground(ColorSelection.fromString(self.workouts[index].color)?.color)
                            .id(UUID())
                        }
                        .onMove { (indices, newOffset) in
                            self.workouts.move(fromOffsets: indices, toOffset: newOffset)
                            _ = DataBase().updateWorkoutIndexes(workouts: workouts)
                        }
                    }
                    .listRowSpacing(verticalSpacer*0.8)
                    .scrollContentBackground(.hidden)
                    .contentMargins(.vertical, verticalSpacer)
                    .listStyle(InsetGroupedListStyle())
                    .listSectionSpacing(CGFloat(verticalSpacer))
                    .navigationBarTitle("Workouts")
                    .navigationBarItems(trailing:
                        Button(action: {
                            self.isAddWorkoutMenuPresented = true
                        }) {
                            Image(systemName: "plus").font(.title2)
                                .foregroundColor(.blue)
                        }.sheet(isPresented: $isAddWorkoutMenuPresented) {
                            WorkoutFormView(
                                isPresented: self.$isAddWorkoutMenuPresented,
                                workouts: self.$workouts,
                                editForWorkout: .constant(
                                    Workout(
                                        id: -1,
                                        name: "",
                                        durationMinutes: 0,
                                        color: "",
                                        chunkSize: 0,
                                        lastCompletedTimestamp: nil
                                    )
                                ),
                                goToAllWorkouts: .constant(false)
                            )
                        }
                    )
            }
        }.onAppear(perform: {
            workouts = DataBase().fetchWorkoutTableRows()
        })
    }
    
    func updateWorkoutsSelected() {
        let dateWithTimeZone: Date = Calendar.current.startOfDay(for: Date()).addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT(for: Date())))
        let dateSince = Calendar.current.date(byAdding: .day, value: -14, to: dateWithTimeZone) ?? dateWithTimeZone
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let formattedDateSince = dateFormatter.string(from: dateSince)
        workoutsCompletedList = DataBase().fetchWorkoutsCompletedTableRows(dateSince: formattedDateSince)
    }
}


extension View {
    @available(iOS 14, *)
    func navigationBarTitleTextColor(_ color: Color) -> some View {
        let uiColor = UIColor(color)
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: uiColor ]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: uiColor ]
        return self
    }
}

//
//  AllWorkoutsList.swift
//  Interval Stopwatch
//
//  Created by Dimitri Cunning on 31/03/2024.
//

import SQLite3
import SwiftUI

struct AllWorkoutsListView: View {
    @State private var isAddWorkoutMenuPresented: Bool = false
    @State private var workouts: [Workout] = []
    @State private var currentSelectedDate: Date = Calendar.current.startOfDay(for: Date()).addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT(for: Date())))
    @State private var lastClickedIndex: Int = 14
    @State private var workoutsCompletedList: [WorkoutsCompleted] = []
        
    init() {
        UITableView.appearance().backgroundColor = .black
        DataBase().createWorkoutsCompletedTable()
        DataBase().createWorkoutTable()
        DataBase().createExerciseTable()
    }
    
    @State private var dateWithTimeZone: Date = Calendar.current.startOfDay(for: Date()).addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT(for: Date())))
    
    
    var body: some View {
        let verticalSpacer: CGFloat = 15
        let workoutPreviewHeight: CGFloat = 50
        let workoutListSpacing: CGFloat = 12
        
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
                
                Spacer().frame(height: verticalSpacer)
                ZStack {//
//                    Color.black.edgesIgnoringSafeArea(.all)
                    List {
                        ForEach(workouts.indices, id: \.self) { index in
                            WorkoutPreview(workout: self.$workouts[index], border: 10)
                            .background(
                                    NavigationLink("", destination: ListExerciseDetails(workout: self.$workouts[index])
                                    ).opacity(0)
                                ).frame(height: workoutPreviewHeight)
                            .swipeActions (edge: .leading) {
                                let workoutIsCompleted: Bool = DataBase().workoutIsCompletedOnDate(workoutId: workouts[index].id, date: currentSelectedDate)
                                let icon: String = workoutIsCompleted ? "xmark" : "checkmark"
                                let tint: Color = workoutIsCompleted ? Color.gray : Color(red: 0, green: 0.5, blue: 0)
                                
                                Button(action: {
                                    if DataBase().toggleOrInsertWorkoutCompletedTableRow(workoutId: workouts[index].id, markedForDate: currentSelectedDate) {
                                    } else {
                                        print("Error executing toggle/insert query")
                                    }
                                    workouts[index].lastCompletedTimestamp = DataBase().updateWorkoutLastCompletedTimestamp(workoutId: workouts[index].id)
                                    workouts = DataBase().fetchWorkoutTableRows()
                                    
                                    updateWorkoutsSelected()
                                }) {
                                    Image(systemName: icon)
                                }.tint(tint)
                            }
                            .listRowBackground(ColorSelection.fromString(self.workouts[index].color)?.color)
                            .id(UUID())
                        }
                        .onMove { (indices, newOffset) in
                            self.workouts.move(fromOffsets: indices, toOffset: newOffset)
                        }
                    }
                    .listRowSpacing(workoutListSpacing)
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
                            AddWorkoutItemFormView(isPresented: self.$isAddWorkoutMenuPresented, workouts: self.$workouts)
                        }
                    )
                    .navigationBarTitleTextColor(.white)
                }//
            }.background(Color.black)
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




#Preview {
    ContentView()
}

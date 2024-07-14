//
//  WorkoutPreview.swift
//  Interval Stopwatch
//
//  Created by Dimitri Cunning on 04/04/2024.
//

import SwiftUI

struct WorkoutPreview: View {
    @Binding var workoutsCompletedList: [WorkoutsCompleted]
    @Binding var currentSelectedDate: Date
    @Binding var workouts: [Workout]
    @Binding var workout: Workout
    var border: CGFloat
    var color: ColorSelection
    
    private var formattedDate: String {
        if let lastCompletedTimestamp = workout.lastCompletedTimestamp {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE, MMMM d"
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            return dateFormatter.string(from: lastCompletedTimestamp)
        }
        return " "
    }
    
    init(workoutsCompletedList: Binding<[WorkoutsCompleted]>, currentSelectedDate: Binding<Date>, workouts: Binding<[Workout]>, workout: Binding<Workout>, border: CGFloat) {
        self._workoutsCompletedList = workoutsCompletedList
        self._currentSelectedDate = currentSelectedDate
        self._workouts = workouts
        self._workout = workout
        self.border = border
        self.color = ColorSelection.fromString(workout.wrappedValue.color) ?? .white
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                if workout.durationMinutes % 60 == 0 {
                    Text("\(workout.durationMinutes / 60)h").foregroundColor(self.color == .black ? Color.white : Color.black)
                } else if workout.durationMinutes < 60 {
                    Text("\(workout.durationMinutes)m").foregroundColor(self.color == .black ? Color.white : Color.black)
                } else {
                    Text("\(workout.durationMinutes / 60)h \(workout.durationMinutes % 60)m").foregroundColor(self.color == .black ? Color.white : Color.black)
                }
                Spacer().frame(width: border/4)
            }
            HStack {
                Spacer().frame(width: border)
                Text("\(workout.name)")
                    .foregroundColor(self.color == .black ? Color.white : Color.black)
                    .font(.title2)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Spacer()
            }
            HStack {
                Spacer()
                Text("\(formattedDate)")
                    .foregroundColor(self.color == .black ? Color.white : Color.black)
                Spacer().frame(width: border/4)
            }
        }
        .padding(-5*border/4)
        .background(.clear)
        .swipeActions (edge: .leading) {
            let workoutIsCompleted: Bool = DataBase().workoutIsCompletedOnDate(workoutId: workout.id, date: currentSelectedDate)
            let icon: String = workoutIsCompleted ? "xmark" : "checkmark"
            let tint: Color = workoutIsCompleted ? Color.gray : Color(red: 0, green: 0.5, blue: 0)
            
            Button(action: {
                if DataBase().toggleOrInsertWorkoutCompletedTableRow(
                    workoutId: workout.id,
                    markedForDate: currentSelectedDate
                ) {
                    workout.lastCompletedTimestamp = DataBase().updateWorkoutLastCompletedTimestamp(
                        workoutId: workout.id
                    )
                    workouts = DataBase().fetchWorkoutTableRows()
                    updateWorkoutsSelected()
                }
            }) {
                Image(systemName: icon)
            }.tint(tint)
        }
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
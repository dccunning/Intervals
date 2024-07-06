//
//  WorkoutPreview.swift
//  Interval Stopwatch
//
//  Created by Dimitri Cunning on 04/04/2024.
//

import SwiftUI

struct WorkoutPreview: View {
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
    
    init(workout: Binding<Workout>, border: CGFloat) {
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
    }
}

//
//  WorkoutLogBars.swift
//  Interval Stopwatch
//
//  Created by Dimitri Cunning on 08/05/2024.
//


import SwiftUI

struct WorkoutLogBars: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var workoutsCompletedList: [WorkoutsCompleted]
    @Binding var currentDatetime: Date
    @Binding var currentSelectedDate: Date
    @Binding var lastClickedIndex: Int
    
    init(workoutsCompletedList: Binding<[WorkoutsCompleted]>, currentDatetime: Binding<Date>, 
         currentSelectedDate: Binding<Date>,  lastClickedIndex: Binding<Int>) {
        self._workoutsCompletedList = workoutsCompletedList
        self._currentDatetime = currentDatetime
        self._currentSelectedDate = currentSelectedDate
        self._lastClickedIndex = lastClickedIndex
    }
    
    var body: some View {
        let barSpacing: CGFloat = 10
        let barHeight: CGFloat = 70
        let selectedColumnColor: Color = colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.2)
        let defaultColumnColor: Color = colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05)
        let weekTextColor: Color = colorScheme == .dark ? Color.white.opacity(0.5) : Color.black.opacity(0.5)
        
        HStack(spacing: barSpacing) {
            ForEach(1..<15) { index in
                let daysToAdd = -(14 - index)
                let selectedDate = Calendar.current.date(byAdding: .day, value: daysToAdd, to: currentDatetime) ?? currentDatetime
                
                VStack {
                    Button(action: {
                        currentSelectedDate = selectedDate
                        lastClickedIndex = index
                    }) {
                        ZStack(alignment: .bottom) {
                            Rectangle().foregroundColor(defaultColumnColor).frame(width: 16, height: barHeight).cornerRadius(1)
                           
                            VStack(spacing: 0) {
                                ForEach(workoutsCompletedList.filter { $0.indexDate == index }.sorted(by: { $0.updatedTimestamp >= $1.updatedTimestamp }), id: \.id) { workoutCompleted in
                                    let totalChunkSize: Int = Int( workoutsCompletedList
                                        .filter { $0.indexDate == index }
                                        .reduce(0) { $0 + ($1.chunkSize ?? 0) })

                                    if totalChunkSize > 10 {
                                        Rectangle().foregroundColor(workoutCompleted.getColor() ?? .red).frame(width: 16, height: CGFloat(barHeight) / CGFloat(totalChunkSize) * CGFloat(workoutCompleted.chunkSize ?? 0))
                                        
                                    } else {
                                        Rectangle()
                                            .foregroundColor(workoutCompleted.getColor() ?? .red).frame(width: 16, height: CGFloat(barHeight) / CGFloat(10) * CGFloat(workoutCompleted.chunkSize ?? 0))
                                    }

                                }
                            }.cornerRadius(1)
                            
                            Rectangle()
                                .foregroundColor(lastClickedIndex == index ? selectedColumnColor : defaultColumnColor)
                                .frame(width: 16, height: barHeight)
                            .cornerRadius(1)
                        }
                        
                    }
                    
                    let dayOfWeekNumber: Int = (Calendar.current.component(.weekday, from: Date()) - 1 + index) % 7
                    let dayOfWeekCharacter: Character = Calendar.current.shortWeekdaySymbols[dayOfWeekNumber].first ?? " "
                    
                    Text(String(dayOfWeekCharacter))
                        .foregroundColor(weekTextColor)
                        .font(.system(size: 10))
                }
            }
        }
    }
}

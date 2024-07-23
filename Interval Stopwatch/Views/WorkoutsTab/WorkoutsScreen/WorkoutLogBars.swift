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
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            let widthPctOfBar: CGFloat = 5/8
            let barWidthAndSpace: CGFloat = screenWidth/(16-3*(1-widthPctOfBar))

            let barSpacing: CGFloat = barWidthAndSpace * (1-widthPctOfBar)
            let barWidth: CGFloat = barWidthAndSpace * (widthPctOfBar)
            let barHeight: CGFloat = max(screenHeight/12, 60)
            
            let selectedColumnColor: Color = colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.2)
            let defaultColumnColor: Color = colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.05)
            let weekTextColor: Color = colorScheme == .dark ? Color.white.opacity(0.5) : Color.black.opacity(0.5)
            
            HStack(spacing: barSpacing) {
                Spacer().frame(width: barWidth-barSpacing)
                ForEach(1..<15) { index in
                    let daysToAdd = -(14 - index)
                    let selectedDate = Calendar.current.date(byAdding: .day, value: daysToAdd, to: currentDatetime) ?? currentDatetime
                    
                    VStack {
                        Button(action: {
                            currentSelectedDate = selectedDate
                            lastClickedIndex = index
                        }) {
                            ZStack(alignment: .bottom) {
                                Rectangle().foregroundColor(defaultColumnColor)
                                    .frame(width: barWidth)
                                    .frame(height: barHeight)
                                    .cornerRadius(1)
                                
                                VStack(spacing: 0) {
                                    ForEach(workoutsCompletedList.filter { $0.indexDate == index }.sorted(by: { $0.updatedTimestamp >= $1.updatedTimestamp }), id: \.id) { workoutCompleted in
                                        let totalChunkSize: Int = Int( workoutsCompletedList
                                            .filter { $0.indexDate == index }
                                            .reduce(0) { $0 + ($1.chunkSize ?? 0) })
                                        
                                        if totalChunkSize > 10 {
                                            Rectangle().foregroundColor(workoutCompleted.getColor() ?? .red).frame(width: barWidth, height: CGFloat(barHeight) / CGFloat(totalChunkSize) * CGFloat(workoutCompleted.chunkSize ?? 0))
                                            
                                        } else {
                                            Rectangle()
                                                .foregroundColor(workoutCompleted.getColor() ?? .red).frame(width: barWidth, height: CGFloat(barHeight) / CGFloat(10) * CGFloat(workoutCompleted.chunkSize ?? 0))
                                        }
                                        
                                    }
                                }.cornerRadius(1)
                                
                                Rectangle()
                                    .foregroundColor(lastClickedIndex == index ? selectedColumnColor : defaultColumnColor)
                                    .frame(width: barWidth)
                                    .frame(height: barHeight)
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
                Spacer().frame(width: barWidth-barSpacing)
            }
    }
}

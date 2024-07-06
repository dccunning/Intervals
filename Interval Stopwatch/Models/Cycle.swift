//
//  IntervalCounter.swift
//  Interval Stopwatch
//
//  Created by Dimitri Cunning on 15/03/2024.
//

import SwiftUI

class Cycle: ObservableObject {
    @Published var selectedCount: Int
    @Published var color: ColorSelection
    @Published var maxNumber = 60

    init(selectedCount: Int = 0, color: ColorSelection) {
        self.selectedCount = selectedCount
        self.color = color
    }
        
    func currentCount(elapsedSeconds: Int, cycleDuration: Int) -> Int {
        if cycleDuration <= 0 {
            return 0
        } else {
            return Int(ceil(Double(elapsedSeconds+1)/Double(cycleDuration)))
        }
    }
    
    func currentIntervalSecondsLeft(stopwatch: Stopwatch, firstInterval: Interval, secondInterval: Interval) -> Int {
        let currentCycleDuration = Int(firstInterval.duration + secondInterval.duration)
        let currentTimeLiesInTheFirstInterval = stopwatch.elapsedSeconds % currentCycleDuration < Int(firstInterval.duration)
        let remainingTimeInterval: Int
        
        if currentTimeLiesInTheFirstInterval {
            remainingTimeInterval = Int(firstInterval.duration) - stopwatch.elapsedSeconds % currentCycleDuration
        } else {
            remainingTimeInterval = Int(secondInterval.duration) - (stopwatch.elapsedSeconds % currentCycleDuration - Int(firstInterval.duration))
        }
        return Int(remainingTimeInterval)
    }
    
    func currentIntervalTimeLeft(stopwatch: Stopwatch, firstInterval: Interval, secondInterval: Interval) -> String {
        let remainingTimeInterval: Int = currentIntervalSecondsLeft(stopwatch: stopwatch, firstInterval: firstInterval, secondInterval: secondInterval)
        
        let seconds = remainingTimeInterval % 60
        let minutes = remainingTimeInterval / 60
        return String(format: "%2d:%02d", minutes, seconds)
    }
}

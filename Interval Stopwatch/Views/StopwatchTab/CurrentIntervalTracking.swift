//
//  CurrentIntervalTracking.swift
//  Interval Stopwatch
//
//  Created by Dimitri Cunning on 08/03/2024.
//

import SwiftUI
import AudioToolbox

struct ViewCurrentIntervalTracking: View {
    @ObservedObject var firstInterval: Interval
    @ObservedObject var secondInterval: Interval
    @ObservedObject var stopwatch: Stopwatch
    @ObservedObject var cycle: Cycle
    var cycleDuration: Int {
        Int(firstInterval.duration + secondInterval.duration)
    }
    var fontHeight: CGFloat
    
    init(stopwatch: Stopwatch, firstInterval: Interval, secondInterval: Interval, cycle: Cycle, fontHeight: CGFloat) {
        self.stopwatch = stopwatch
        self.firstInterval = firstInterval
        self.secondInterval = secondInterval
        self.cycle = cycle
        self.fontHeight = fontHeight
    }
    
    var body: some View {
        if cycleDuration >= 0 {
            let minusSecondInterval: Int = if firstInterval.duration > 0 { Int(secondInterval.duration) } else { 0 }
            let showFinalTimeCount = cycle.selectedCount > 0 && stopwatch.elapsedSeconds >= cycle.selectedCount * cycleDuration - minusSecondInterval

            HStack (spacing: 0) {
                if showFinalTimeCount || cycleDuration==0 {// Display finished state
                    Text("\(cycle.selectedCount)")
                        .foregroundColor(cycleDuration==0 ? .clear : cycle.color.color)
                        .font(.system(size: fontHeight).monospacedDigit())
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Text(String(format: "%2d:%02d", 0, 0))
                        .foregroundColor(cycleDuration==0 ? .clear : cycle.color.color)
                        .font(.system(size: fontHeight).monospacedDigit())
                        .frame(maxWidth: .infinity, alignment: .center)
                        .onAppear {
                            if stopwatch.isRunning {
                                stopwatch.stopTimer(playEndSound: true)
                            }
                        }
                }
                else {// Display running state
                    let currentColor = calculateColor()
                    let currentCycleCount = cycle.currentCount(elapsedSeconds: stopwatch.elapsedSeconds, cycleDuration: cycleDuration)
                    let currentIntervalTimeLeftString = cycle.currentIntervalTimeLeft(stopwatch: stopwatch, firstInterval: firstInterval, secondInterval: secondInterval)
                    let countOrColor = "\(currentColor) \(currentCycleCount)"
                    
                    Text("\(currentCycleCount)").foregroundColor(currentColor).font(.system(size: fontHeight).monospacedDigit())
                        .frame(maxWidth: .infinity, alignment: .center
                    ).onChange(of: countOrColor) {
                        playSoundFor(color: calculateColor())
                    }
                    Text("\(currentIntervalTimeLeftString)").foregroundColor(currentColor)
                        .font(.system(size: fontHeight).monospacedDigit())
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }
    
    private func calculateColor() -> Color {
        if stopwatch.elapsedSeconds % cycleDuration < Int(firstInterval.duration) {
            return firstInterval.color.color
        }
        else {
            return secondInterval.color.color
        }
    }
    
    private func playSoundFor(color: Color) {
        guard stopwatch.isRunning else {
            return
        }
        if color == firstInterval.color.color {
            SoundPlayer.playSound(firstInterval.sound)
        } else {
            SoundPlayer.playSound(secondInterval.sound)
        }
    }

}


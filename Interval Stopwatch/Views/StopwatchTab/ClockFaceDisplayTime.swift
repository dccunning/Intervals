//
//  ClockFaceDisplayTime.swift
//  Interval Stopwatch
//
//  Created by Dimitri Cunning on 08/03/2024.
//

import SwiftUI

class NextLine {
    var second: Int
    var color: Color
    var hide: Bool = false
    
    init(second: Int = 0, color: Color = .clear) {
        self.second = second
        self.color = color
    }
}

struct ViewClockFaceDisplayTime: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var stopwatch: Stopwatch
    @ObservedObject var cycle: Cycle
    @ObservedObject var firstInterval: Interval
    @ObservedObject var secondInterval: Interval
    var clockWidth: CGFloat
    var timeFont: CGFloat
    var halfWayDownFromClockCenter: CGFloat {clockWidth/4}
    var cycleDuration: Int { Int(firstInterval.duration + secondInterval.duration) }
    var atLeastOneIntervalSet: Bool { cycleDuration > 0 }
    
    
    init(stopwatch: Stopwatch, cycle: Cycle, firstInterval: Interval, secondInterval: Interval, clockWidth: CGFloat, timeFont: CGFloat) {
        self.stopwatch = stopwatch
        self.cycle = cycle
        self.firstInterval = firstInterval
        self.secondInterval = secondInterval
        self.clockWidth = clockWidth
        self.timeFont = timeFont
    }
    
    var body: some View {
        let timeColor: Color = colorScheme == .dark ? .white : .black
        ZStack {
            if colorScheme == .dark {
                Image("svg_white_face_detailed").resizable().aspectRatio(contentMode: .fit)
                    .frame(width: clockWidth, height: clockWidth)
            } else {
                Image("svg_black_face_detailed").resizable().aspectRatio(contentMode: .fit)
                    .frame(width: clockWidth, height: clockWidth)
            }
            
                        
            if stopwatch.showEndLines && atLeastOneIntervalSet {
                let line = getNextLine()
                if !line.hide {
                    Image("svg_white_hand").renderingMode(.template).resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: clockWidth, height: clockWidth)
                            .rotationEffect(Angle(degrees: Double(line.second) * 6), anchor: UnitPoint(x: 0.5, y: 0.5))
                            .foregroundColor(line.color)
                }
            }

            // Display second hand
            Image("svg_hand_100px_green").resizable().aspectRatio(contentMode: .fit)
                .frame(width: clockWidth, height: clockWidth)
                .rotationEffect(rotationAngle, anchor: UnitPoint(x: 0.5, y: 0.5))
            
            // Display digital time
            Text("\(formattedElapsedTime())")
                .font(Font.system(size: timeFont).monospacedDigit())
                .foregroundColor(timeColor)
                .offset(y: halfWayDownFromClockCenter)
        }
    }
    
    private var rotationAngle: Angle {
        return Angle(degrees: stopwatch.elapsedTime * 6)
    }
    
    private func formattedElapsedTime() -> String {
        let hundredths = Int(stopwatch.elapsedTime * 100) % 100
        let seconds = Int(stopwatch.elapsedTime) % 60
        let minutes = Int(stopwatch.elapsedTime) / 60
        return String(format: "%02d:%02d.%02d", minutes, seconds, hundredths)
    }
    
    private func getNextLine() -> NextLine {
        let currentCount = cycle.currentCount(elapsedSeconds: stopwatch.elapsedSeconds, cycleDuration: cycleDuration)
        let line: NextLine = NextLine()
        let minusSecondInterval: Int = if firstInterval.duration > 0 { Int(secondInterval.duration) } else { 0 }

        
        // Final line
        if (cycle.selectedCount>0 && cycle.selectedCount==currentCount
        ) {
            line.second = currentCount * cycleDuration - minusSecondInterval
            line.color = cycle.color.color
        }
        // Active line
        else if (stopwatch.elapsedSeconds % cycleDuration < Int(firstInterval.duration)) {
            line.second = currentCount * cycleDuration - Int(secondInterval.duration)
            line.color = firstInterval.color.color
        }
        // Rest line
        else if (stopwatch.elapsedSeconds % cycleDuration >= Int(firstInterval.duration) || (Int(firstInterval.duration) == 0 && secondInterval.duration > 0)) {
            line.second = currentCount * cycleDuration
            line.color = secondInterval.color.color
        }
        
        // Hide conditions
        let finalIntervalHasFinished: Bool = cycle.selectedCount > 0 && stopwatch.elapsedSeconds >= cycle.selectedCount * cycleDuration - minusSecondInterval
        let nextLineAppearsAfter60sFromNow: Bool = line.second > stopwatch.elapsedSeconds + 60
        
        line.hide = finalIntervalHasFinished || nextLineAppearsAfter60sFromNow

        return line
    }
    
}

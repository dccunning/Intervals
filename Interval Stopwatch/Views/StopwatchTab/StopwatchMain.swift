//
//  ContentView.swift
//  Interval Stopwatch
//
//  Created by Dimitri Cunning on 22/02/2024.
//

import SwiftUI
import AudioToolbox
import AVFoundation

struct ViewStopwatchMain: View {
    @State private var isSettingsPresented = false
    @State private var mySettings: Settings
    @StateObject private var myStopwatch: Stopwatch
    @StateObject private var myCycle: Cycle
    @StateObject private var activeInterval: Interval
    @StateObject private var restInterval: Interval
    
    
    init(settings: Settings, activeInterval: TimeInterval = 0, restInterval: TimeInterval = 0, cycleCount: Int = 0) {
        self.mySettings = settings
        _myStopwatch = StateObject(wrappedValue: Stopwatch(endSound: settings.endSound, showEndLines: settings.showEndLines))
        _myCycle = StateObject(wrappedValue: Cycle(selectedCount: cycleCount, color: settings.countColor))
        _activeInterval = StateObject(wrappedValue: Interval(duration: activeInterval, name: "Active interval", color: settings.activeColor, sound: settings.activeSound))
        _restInterval = StateObject(wrappedValue: Interval(duration: restInterval, name: "Rest interval", color: settings.restColor, sound: settings.restSound))
    }
    
    var startSound: SoundPlayer.SystemSound {
        if activeInterval.duration > 0 {return activeInterval.sound}
        else if restInterval.duration > 0 {return restInterval.sound}
        else {return .off}
    }
    var currentCycleDuration: Int {
        Int(activeInterval.duration + restInterval.duration)
    }

    var body: some View {
        GeometryReader { geometry in
            let borderPct: CGFloat = 0.05
            let border: CGFloat = borderPct*geometry.size.width
            let screenHeight: CGFloat = geometry.size.height
            let screenWidth: CGFloat = geometry.size.width
            let widthMinusBorder: CGFloat = geometry.size.width-2*border
            
            VStack(spacing: 0) {
                let clockWidth: CGFloat = min(screenHeight/2, widthMinusBorder)
                ZStack {
                    // max 50% height
                    ViewClockFaceDisplayTime(
                        stopwatch: myStopwatch,
                        cycle: myCycle,
                        firstInterval: activeInterval,
                        secondInterval: restInterval,
                        clockWidth: clockWidth,
                        timeFont: clockWidth*0.065
                    )
                    
                    let gearFont: CGFloat = clockWidth*0.07
                    Button(action: {isSettingsPresented.toggle()}) {
                        Image(systemName: "gear").font(Font.system(size: gearFont)).padding()
                    }
                    .offset(x: (screenWidth-gearFont)/2-border, y: -(clockWidth-gearFont)/2)
                }
                .sheet(isPresented: $isSettingsPresented) {
                    ViewSettings(settings: mySettings, isPresented: $isSettingsPresented, stopwatch: myStopwatch, cycle: myCycle, firstInterval: activeInterval, secondInterval: restInterval)
                }
                
                // max 12.5% height
                ViewTimeControl(
                    stopwatch: myStopwatch,
                    startSound: startSound,
                    circleWidth: clockWidth/4,
                    border: border
                )
                                    
                VStack(alignment: .leading, spacing: 0) {
                    // max 25% height
                    ViewInputTimeInterval(
                        interval: activeInterval,
                        settings: mySettings,
                        height: min(screenHeight/12, 50),
                        width: screenWidth,
                        border: border
                    ).disabled(myStopwatch.isRunning)
                    
                    ViewInputTimeInterval(
                        interval: restInterval,
                        settings: mySettings,
                        height: min(screenHeight/12, 50),
                        width: screenWidth,
                        border: border
                    ).disabled(myStopwatch.isRunning)
                    
                    ViewInputIntervalCount(
                        cycle: myCycle,
                        settings: mySettings,
                        height: min(screenHeight/12, 50),
                        width: screenWidth,
                        border: border
                    ).disabled(myStopwatch.isRunning || currentCycleDuration == 0)
                    
                    
                    Spacer()
                    // max 12.5% height
                    HStack(spacing: 0) {
                        Spacer().frame(width: border)
                        ViewCurrentIntervalTracking(
                            stopwatch: myStopwatch,
                            firstInterval: activeInterval,
                            secondInterval: restInterval,
                            cycle: myCycle,
                            fontHeight: min(screenHeight/12, 60)
                        )
                        Spacer().frame(width: border)
                    }
                    Spacer()
                    
                    
                }.onChange(of: currentCycleDuration) {
                    if currentCycleDuration == 0 {
                        myCycle.selectedCount = 0
                    }
                }
                
            }
        }
        
    }
}

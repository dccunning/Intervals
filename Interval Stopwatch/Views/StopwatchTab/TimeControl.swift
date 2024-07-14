//
//  TimeControl.swift
//  Interval Stopwatch
//
//  Created by Dimitri Cunning on 08/03/2024.
//

import SwiftUI
import AudioToolbox

struct ViewTimeControl: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var stopwatch: Stopwatch
    var startSound: SoundPlayer.SystemSound
    var circleWidth: CGFloat
    var border: CGFloat
    
    init(stopwatch: Stopwatch, startSound: SoundPlayer.SystemSound, circleWidth: CGFloat, border: CGFloat) {
        self.stopwatch = stopwatch
        self.startSound = startSound
        self.circleWidth = circleWidth
        self.border = border
    }
    
    var body: some View {
        let modeStringNameAddon: String = colorScheme == .dark ? "" : "_light_mode"
        HStack(alignment: .center) { // Timer control buttons
            Spacer().frame(width: border)
            
            if stopwatch.isPaused && stopwatch.elapsedTime > 0 { // Timer is paused: Start or reset.
                Button {
                    stopwatch.resetTimer()
                } label: {
                    Image("svg_reset_button\(modeStringNameAddon)").resizable().aspectRatio(contentMode: .fit)
                        .frame(width: circleWidth, height: circleWidth)
                }.contentShape(Circle())
                
                Spacer()

                Button {
                    stopwatch.startTimer()
                } label: {
                    Image("svg_start_timer\(modeStringNameAddon)").resizable().aspectRatio(contentMode: .fit)
                        .frame(width: circleWidth, height: circleWidth)
                }.contentShape(Circle())
            } else if stopwatch.isRunning { // Timer is running: Pause.
                Image("svg_grey_unbutton\(modeStringNameAddon)").resizable().aspectRatio(contentMode: .fit)
                    .frame(width: circleWidth, height: circleWidth)
                
                Spacer()

                Button {
                    stopwatch.stopTimer()
                } label: {
                    Image("svg_stop_timer\(modeStringNameAddon)").resizable().aspectRatio(contentMode: .fit)
                        .frame(width: circleWidth, height: circleWidth)
                }.contentShape(Circle())
            } else { // Timer is in restarted state: Start.
                Image("svg_grey_unbutton\(modeStringNameAddon)").resizable().aspectRatio(contentMode: .fit)
                    .frame(width: circleWidth, height: circleWidth)
                
                Spacer()
                
                Button {
                    stopwatch.startTimer(startSound: startSound)
                } label: {
                    Image("svg_start_timer\(modeStringNameAddon)").resizable().aspectRatio(contentMode: .fit)
                        .frame(width: circleWidth, height: circleWidth)
                }.contentShape(Circle())
            }
            Spacer().frame(width: border)
        }
    }
}

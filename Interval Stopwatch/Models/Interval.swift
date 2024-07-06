//
//  Interval.swift
//  Interval Stopwatch
//
//  Created by Dimitri Cunning on 11/03/2024.
//

import Foundation
import SwiftUI
import AudioToolbox

class Interval: ObservableObject {
    @Published var duration: TimeInterval
    @Published var name: String
    @Published var color: ColorSelection
    @Published var sound: SoundPlayer.SystemSound
    
    init(duration: TimeInterval = 0, name: String, color: ColorSelection, sound: SoundPlayer.SystemSound) {
        self.duration = duration
        self.name = name
        self.color = color
        self.sound = sound
    }
}

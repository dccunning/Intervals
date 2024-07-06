//
//  Stopwatch.swift
//  Interval Stopwatch
//
//  Created by Dimitri Cunning on 14/03/2024.
//

import SwiftUI

class Stopwatch: ObservableObject {
    private var timer: Timer?
    @Published var isPaused: Bool = true
    @Published var isRunning: Bool = false
    @Published var elapsedTime: TimeInterval = 0
    var elapsedSeconds: Int { return Int(elapsedTime) }
    @Published var endSound: SoundPlayer.SystemSound
    @Published var showEndLines: Bool
    
    init (endSound: SoundPlayer.SystemSound, showEndLines: Bool = false) {
        self.endSound = endSound
        self.showEndLines = showEndLines
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func startTimer(startSound: SoundPlayer.SystemSound = .off) {
        if self.elapsedTime == 0 && startSound != .off {
            SoundPlayer.playSound(startSound)
        }
        self.isRunning = true
        self.isPaused = false
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: self.isRunning) { _ in
            self.elapsedTime += 0.01}
    }
    
    func stopTimer(playEndSound: Bool = false) {
        if playEndSound {
            SoundPlayer.playSound(endSound)
        }
        self.isRunning = false
        self.isPaused = true
        self.timer?.invalidate()
        self.timer = nil
    }

    func resetTimer() {
        self.isRunning = false
        self.isPaused = true
        self.timer?.invalidate()
        self.timer = nil
        self.elapsedTime = 0
    }
}

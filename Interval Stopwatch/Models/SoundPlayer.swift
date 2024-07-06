//
//  SoundPlayer.swift
//  Interval Stopwatch
//
//  Created by Dimitri Cunning on 15/03/2024.
//

import AudioToolbox

class SoundPlayer {
    
    enum SystemSound: UInt32, CaseIterable {
        case off = 0
        case orbDongDong = 1060
        case alienPhoneCallEnd = 1061
        case lowBeep = 1070
        case quickLowBeep = 1071
        case annoyingBeeps = 1073
        case doubleTapElectric = 1075
        case fourXBlob = 1109
        case heavySlowKong = 1110
        case lightKong = 1111
        case lightSlowKong = 1112
        case tripleChimePause = 1115
        case tripleChimePlay = 1116
        case facetimeConnected = 1150
        case loudFacetimeRing = 1151
        case facetimeEnded = 1152
        case slowDoubleBeep = 1153
        case facetimeRing = 1154
        case fastFiveNotes = 1165
        case loudEndingChime = 1253
        case longBeepShortBeep = 1254
        case quickDoubleBeep = 1255
        case doubleEndBeep = 1256
        case quickHighLowEnding = 1264
        case quickStartChime = 1272
        case quickPauseChime = 1273
        case quickTripleChime = 1274
        case email = 1302
        case reminder = 1304
        case oldRing = 1308
        case oldTriangle = 1313
        case alienRing = 1314
        case incomingDoubleNotification = 1317
        case train = 1323
        case shortLoudStart = 1340
        case shortLoudPause = 1341
        case shortLoudFinish = 1342
        case loudDoubleTap = 1404
        case loudHighEndingChime = 1405
        case slowDoubleTapStart = 1556
        case slowDoubleTapEnd = 1557
        
        var displayName: String {
            switch self {
            case .off: return "Off"
            case .orbDongDong: return "Mystic Orb Gong"
            case .alienPhoneCallEnd: return "Galactic Hangup"
            case .lowBeep: return "Whispering Echo"
            case .quickLowBeep: return "Speedy Boop"
            case .annoyingBeeps: return "Annoying Symphony"
            case .doubleTapElectric: return "Zap 'n' Tap"
            case .fourXBlob: return "Quadruple Blob"
            case .heavySlowKong: return "Titanic Kong"
            case .lightKong: return "Nimble Kong"
            case .lightSlowKong: return "Graceful Kong"
            case .tripleChimePause: return "Trinity Chime Play"
            case .tripleChimePlay: return "Trinity Chime Pause"
            case .facetimeConnected: return "Cosmic Connection"
            case .loudFacetimeRing: return "Thundering Call"
            case .facetimeEnded: return "Interstellar Farewell"
            case .slowDoubleBeep: return "Slothful Beep"
            case .facetimeRing: return "Galactic Ringtone"
            case .fastFiveNotes: return "Velocity Symphony"
            case .loudEndingChime: return "Earshattering Chime"
            case .longBeepShortBeep: return "Extended Boop"
            case .quickDoubleBeep: return "Rapid Bip-Bop"
            case .doubleEndBeep: return "Twofold Bloop"
            case .quickHighLowEnding: return "Speedy Ups 'n' Downs"
            case .quickStartChime: return "Hasty Prelude Start"
            case .quickPauseChime: return "Hasty Prelude Pause"
            case .quickTripleChime: return "Threefold Crescendo"
            case .email: return "Electronic Post"
            case .reminder: return "Memory Jab"
            case .oldRing: return "Ancient Chime"
            case .oldTriangle: return "Antique Bell"
            case .alienRing: return "Extraterrestrial Bell"
            case .incomingDoubleNotification: return "Dual Arrival"
            case .train: return "Locomotive Roar"
            case .shortLoudStart: return "Fleeting Hush Start"
            case .shortLoudPause: return "Fleeting Hush Pause"
            case .shortLoudFinish: return "Fleeting Hush Finish"
            case .loudDoubleTap: return "Thunderous Tapping"
            case .loudHighEndingChime: return "Grand Finale Chime"
            case .slowDoubleTapStart: return "Relaxed Tapping Begining"
            case .slowDoubleTapEnd: return "Relaxed Tapping Finale"
            }
        }
    }
    
    static func playSound(_ sound: SystemSound) {
        let soundIsOn: Bool
        if UserDefaults.standard.object(forKey: "soundEnabled") == nil {
            soundIsOn = sound != .off
        } else {
            soundIsOn = sound != .off && UserDefaults.standard.bool(forKey: "soundEnabled")
        }
        if soundIsOn {
            AudioServicesPlaySystemSound(sound.rawValue)
        }

    }
}

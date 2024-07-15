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
        case tripleChimePlay = 1115
        case tripleChimePause = 1116
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
            case .oldRing: return "Ancient Chime"
            case .annoyingBeeps: return "Annoying Symphony"
            case .oldTriangle: return "Antique Bell"
            case .facetimeConnected: return "Cosmic Connection"
            case .incomingDoubleNotification: return "Dual Arrival"
            case .loudEndingChime: return "Earshattering Chime"
            case .email: return "Electronic Post"
            case .longBeepShortBeep: return "Extended Boop"
            case .alienRing: return "Extraterrestrial Bell"
            case .shortLoudFinish: return "Fleeting Hush Finish"
            case .shortLoudPause: return "Fleeting Hush Pause"
            case .shortLoudStart: return "Fleeting Hush Start"
            case .alienPhoneCallEnd: return "Galactic Hangup"
            case .facetimeRing: return "Galactic Ringtone"
            case .lightSlowKong: return "Graceful Kong"
            case .loudHighEndingChime: return "Grand Finale Chime"
            case .quickPauseChime: return "Hasty Prelude Pause"
            case .quickStartChime: return "Hasty Prelude Start"
            case .facetimeEnded: return "Interstellar Farewell"
            case .train: return "Locomotive Roar"
            case .reminder: return "Memory Jab"
            case .orbDongDong: return "Mystic Orb Gong"
            case .lightKong: return "Nimble Kong"
            case .fourXBlob: return "Quadruple Blob"
            case .quickDoubleBeep: return "Rapid Bip-Bop"
            case .slowDoubleTapStart: return "Relaxed Tapping Begining"
            case .slowDoubleTapEnd: return "Relaxed Tapping Finale"
            case .slowDoubleBeep: return "Slothful Beep"
            case .quickLowBeep: return "Speedy Boop"
            case .quickHighLowEnding: return "Speedy Ups 'n' Downs"
            case .quickTripleChime: return "Threefold Crescendo"
            case .loudFacetimeRing: return "Thundering Call"
            case .loudDoubleTap: return "Thunderous Tapping"
            case .heavySlowKong: return "Titanic Kong"
            case .tripleChimePause: return "Trinity Chime Pause"
            case .tripleChimePlay: return "Trinity Chime Play"
            case .doubleEndBeep: return "Twofold Bloop"
            case .fastFiveNotes: return "Velocity Symphony"
            case .lowBeep: return "Whispering Echo"
            case .doubleTapElectric: return "Zap 'n' Tap"
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

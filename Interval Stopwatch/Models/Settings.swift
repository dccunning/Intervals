//
//  Settings.swift
//  Interval Stopwatch
//
//  Created by Dimitri Cunning on 12/03/2024.
//

import SwiftUI

enum PickerStyleSelection {
    case wheel
    case dropDown
    
    var displayName: String {
        switch self {
        case .wheel: return "Wheel"
        case .dropDown: return "Drop down"
        }
    }
}

enum ColorSelection: String, CaseIterable {
    case blue
    case red
    case purple
    case yellow
    case green
    case orange
    case white
    case gray
    case black
    case clear
    
    var color: Color {
        switch self {
        case .blue: return .blue
        case .red: return .red
        case .purple: return .purple
        case .yellow: return .yellow
        case .green: return .green
        case .orange: return .orange
        case .white: return .white
        case .gray: return .gray
        case .black: return .black
        case .clear: return .clear
        }
    }
    
    var displayName: String {
        switch self {
        case .blue: return "Blue"
        case .red: return "Red"
        case .purple: return "Purple"
        case .yellow: return "Yellow"
        case .green: return "Green"
        case .orange: return "Orange"
        case .white: return "White"
        case .gray: return "Gray"
        case .black: return "Black"
        case .clear: return "None"
        }
    }
    
    static func fromString(_ string: String) -> ColorSelection? {
        return ColorSelection(rawValue: string.lowercased())
    }
}


class Settings: ObservableObject {
    @Published var soundEnabled: Bool {didSet {UserDefaults.standard.set(soundEnabled, forKey: "soundEnabled")}}
    @Published var showEndLines: Bool {didSet {UserDefaults.standard.set(showEndLines, forKey: "showEndLines")}}
    @Published var pickerStyle: String {didSet {UserDefaults.standard.set(pickerStyle, forKey: "pickerStyle")}}
    @Published var activeColor: ColorSelection {didSet {UserDefaults.standard.set(activeColor.rawValue, forKey: "activeColor")}}
    @Published var restColor: ColorSelection {didSet {UserDefaults.standard.set(restColor.rawValue, forKey: "restColor")}}
    @Published var countColor: ColorSelection {didSet {UserDefaults.standard.set(countColor.rawValue, forKey: "countColor")}}
    @Published var activeSound: SoundPlayer.SystemSound {didSet {UserDefaults.standard.set(activeSound.rawValue, forKey: "activeSound")}}
    @Published var restSound: SoundPlayer.SystemSound {didSet {UserDefaults.standard.set(restSound.rawValue, forKey: "restSound")}}
    @Published var endSound: SoundPlayer.SystemSound {didSet {UserDefaults.standard.set(endSound.rawValue, forKey: "endSound")}}
    @Published var tabSelectedValue: Int {didSet {UserDefaults.standard.set(tabSelectedValue, forKey: "tabSelectedValue")}}

    
    init() {// Initialise settings for first use of app with User Defaults
        if let soundEnabledValue = UserDefaults.standard.object(forKey: "soundEnabled") {
            self.soundEnabled = soundEnabledValue as? Bool ?? true
        } else {
            UserDefaults.standard.set(true, forKey: "soundEnabled")
            self.soundEnabled = true
        }
        
        if let showEndLinesValue = UserDefaults.standard.object(forKey: "showEndLines") {
            self.showEndLines = showEndLinesValue as? Bool ?? true
        } else {
            UserDefaults.standard.set(true, forKey: "showEndLines")
            self.showEndLines = true
        }
        
        if let pickerStyleValue = UserDefaults.standard.string(forKey: "pickerStyle") {
            self.pickerStyle = pickerStyleValue
        } else {
            UserDefaults.standard.set(PickerStyleSelection.wheel.displayName, forKey: "pickerStyle")
            self.pickerStyle = PickerStyleSelection.wheel.displayName
        }
        
        if let activeColorRawValue = UserDefaults.standard.string(forKey: "activeColor"),
           let activeColor = ColorSelection(rawValue: activeColorRawValue) {
            self.activeColor = activeColor
        } else {
            UserDefaults.standard.set(ColorSelection.blue.rawValue, forKey: "activeColor")
            self.activeColor = ColorSelection.blue
        }
        
        if let restColorRawValue = UserDefaults.standard.string(forKey: "restColor"),
           let restColor = ColorSelection(rawValue: restColorRawValue) {
            self.restColor = restColor
        } else {
            UserDefaults.standard.set(ColorSelection.gray.rawValue, forKey: "restColor")
            self.restColor = ColorSelection.gray
        }
        
        if let countColorRawValue = UserDefaults.standard.string(forKey: "countColor"),
           let countColor = ColorSelection(rawValue: countColorRawValue) {
            self.countColor = countColor
        } else {
            UserDefaults.standard.set(ColorSelection.red.rawValue, forKey: "countColor")
            self.countColor = ColorSelection.red
        }
        
        if let activeSoundRawValue = UserDefaults.standard.object(forKey: "activeSound") as? UInt32,
           let activeSoundValue = SoundPlayer.SystemSound(rawValue: activeSoundRawValue) {
            self.activeSound = activeSoundValue
        } else {
            UserDefaults.standard.set(SoundPlayer.SystemSound.orbDongDong.rawValue, forKey: "activeSound")
            self.activeSound = SoundPlayer.SystemSound.orbDongDong
        }
        
        if let restSoundRawValue = UserDefaults.standard.object(forKey: "restSound") as? UInt32,
           let restSoundValue = SoundPlayer.SystemSound(rawValue: restSoundRawValue) {
            self.restSound = restSoundValue
        } else {
            UserDefaults.standard.set(SoundPlayer.SystemSound.tripleChimePlay.rawValue, forKey: "restSound")
            self.restSound = SoundPlayer.SystemSound.tripleChimePlay
        }
        
        if let endSoundRawValue = UserDefaults.standard.object(forKey: "endSound") as? UInt32,
           let endSoundValue = SoundPlayer.SystemSound(rawValue: endSoundRawValue) {
            self.endSound = endSoundValue
        } else {
            UserDefaults.standard.set(SoundPlayer.SystemSound.loudDoubleTap.rawValue, forKey: "endSound")
            self.endSound = SoundPlayer.SystemSound.loudDoubleTap
        }
        
        if let tabSelectedValueRaw = UserDefaults.standard.object(forKey: "tabSelectedValue") {
            self.tabSelectedValue = tabSelectedValueRaw as? Int ?? 1
        } else {
            UserDefaults.standard.set(true, forKey: "tabSelectedValue")
            self.tabSelectedValue = 1
        }

    }
}

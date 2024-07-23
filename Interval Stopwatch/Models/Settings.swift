//
//  Settings.swift
//  Interval Stopwatch
//
//  Created by Dimitri Cunning on 12/03/2024.
//

import SwiftUI

enum MeasurementSystem: String, CaseIterable {
    case metric
    case imperial
    
    var displayName: String {
        switch self {
        case .metric: return "Kilos"
        case .imperial: return "Pounds"
        }
    }
    
    var shortForm: String {
        switch self {
        case .metric: return "kg"
        case .imperial: return "lbs"
        }
    }
    
    var multiplier: Double {
        switch self {
        case .metric: return 1.25
        case .imperial: return 2.5
        }
    }
}

enum AppColorScheme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}

enum ColorSelection: String, CaseIterable {
    case red
    case orange
    case green
    case blue
    case purple
    case gray
    case white
    case black
    case clear
    case deepRed
    case darkRed
    case forestGreen
    case charcoalGreen
    case turquoise
    case lightBlue
    case mediumBlue
    case deepBlue
    case lightPink
    case darkViolet
    case beige
    case silver
    case slateGray
    case jetGray
    
    var color: Color {
        switch self {
        case .red: return .red
        case .orange: return Color(red: 250/255, green: 117/255, blue: 0/255)
        case .green: return Color(red: 0/255, green: 137/255, blue: 72/255)
        case .blue: return .blue
        case .purple: return Color(red: 85/255, green: 64/255, blue: 201/255)
        case .gray: return .gray
        case .white: return .white
        case .black: return .black
        case .clear: return .clear
        case .deepRed: return Color(red: 164/255, green: 36/255, blue: 59/255)
        case .darkRed: return Color(red: 180/255, green: 0/255, blue: 15/255)
        case .forestGreen: return Color(red: 22/255, green: 86/255, blue: 65/255)
        case .charcoalGreen: return Color(red: 39/255, green: 62/255, blue: 71/255)
        case .turquoise: return Color(red: 0/255, green: 173/255, blue: 173/255)
        case .lightBlue: return Color(red: 137/255, green: 170/255, blue: 230/255)
        case .mediumBlue: return Color(red: 4/255, green: 113/255, blue: 166/255)
        case .deepBlue: return Color(red: 35/255, green: 79/255, blue: 123/255)
        case .lightPink: return Color(red: 222/255, green: 127/255, blue: 164/255)
        case .darkViolet: return Color(red: 68/255, green: 56/255, blue: 80/255)
        case .beige: return Color(red: 222/255, green: 195/255, blue: 164/255)
        case .silver: return Color(red: 192/255, green: 197/255, blue: 193/255)
        case .slateGray: return Color(red: 125/255, green: 132/255, blue: 145/255)
        case .jetGray: return Color(red: 50/255, green: 47/255, blue: 48/255)

        }
    }
    
    var textColor: Color {
        switch self {
        case .red: return .black
        case .orange: return .black
        case .green: return .black
        case .blue: return .black
        case .purple: return .white
        case .gray: return .black
        case .white: return .black
        case .black: return .white
        case .clear: return .clear
        case .deepRed: return .white
        case .darkRed: return .white
        case .forestGreen: return .white
        case .charcoalGreen: return .white
        case .turquoise: return .black
        case .lightBlue: return .black
        case .mediumBlue: return .black
        case .deepBlue: return .white
        case .lightPink: return .black
        case .darkViolet: return .white
        case .beige: return .black
        case .silver: return .black
        case .slateGray: return .black
        case .jetGray: return .white
        }
    }
    
    var displayName: String {
        switch self {
        case .red: return "Red"
        case .orange: return "Orange"
        case .green: return "Green"
        case .blue: return "Blue"
        case .purple: return "Purple"
        case .gray: return "Gray"
        case .white: return "White"
        case .black: return "Black"
        case .clear: return "None"
        case .deepRed: return "Deep Red"
        case .darkRed: return "Dark Red"
        case .forestGreen: return "Forest Green"
        case .charcoalGreen: return "Charcoal Green"
        case .turquoise: return "Turquoise"
        case .lightBlue: return "Light Blue"
        case .mediumBlue: return "Medium Blue"
        case .deepBlue: return "Deep Blue"
        case .lightPink: return "Light Pink"
        case .darkViolet: return "Dark Violet"
        case .beige: return "Beige"
        case .silver: return "Silver"
        case .slateGray: return "Slate Gray"
        case .jetGray: return "Jet Gray"
        }
    }
    
    static func fromString(_ string: String) -> ColorSelection? {
        return self.allCases.first { $0.displayName.lowercased() == string.lowercased() }
    }
}

extension ColorSelection {
    static var allNonClearColors: [ColorSelection] {
        return allCases.filter { $0 != .clear }
    }
    
    static var allButBlackAndWhite: [ColorSelection] {
        return allCases.filter { $0 != .black && $0 != .white }
    }
}

extension Color {
    func lighter(by percentage: CGFloat = 30) -> Color {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return self
        }
        
        let red = max(components[0] + percentage/100, 0)
        let green = max(components[1] + percentage/100, 0)
        let blue = max(components[2] + percentage/100, 0)
        
        return Color(red: Double(red), green: Double(green), blue: Double(blue))
    }
}


class Settings: ObservableObject {
    @Published var soundEnabled: Bool {didSet {UserDefaults.standard.set(soundEnabled, forKey: "soundEnabled")}}
    @Published var showEndLines: Bool {didSet {UserDefaults.standard.set(showEndLines, forKey: "showEndLines")}}
    @Published var activeColor: ColorSelection {didSet {UserDefaults.standard.set(activeColor.rawValue, forKey: "activeColor")}}
    @Published var restColor: ColorSelection {didSet {UserDefaults.standard.set(restColor.rawValue, forKey: "restColor")}}
    @Published var countColor: ColorSelection {didSet {UserDefaults.standard.set(countColor.rawValue, forKey: "countColor")}}
    @Published var activeSound: SoundPlayer.SystemSound {didSet {UserDefaults.standard.set(activeSound.rawValue, forKey: "activeSound")}}
    @Published var restSound: SoundPlayer.SystemSound {didSet {UserDefaults.standard.set(restSound.rawValue, forKey: "restSound")}}
    @Published var endSound: SoundPlayer.SystemSound {didSet {UserDefaults.standard.set(endSound.rawValue, forKey: "endSound")}}
    @Published var tabSelectedValue: Int {didSet {UserDefaults.standard.set(tabSelectedValue, forKey: "tabSelectedValue")}}
    @Published var measurementSystem: MeasurementSystem {didSet {UserDefaults.standard.set(measurementSystem.rawValue, forKey: "measurementSystem")}}
    @Published var appDisplayMode: AppColorScheme {didSet {UserDefaults.standard.set(appDisplayMode.rawValue, forKey: "appDisplayMode")}}

    
    init() {// Initialising settings for first use of app with User Defaults
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
            UserDefaults.standard.set(SoundPlayer.SystemSound.tripleChimePlay.rawValue, forKey: "activeSound")
            self.activeSound = SoundPlayer.SystemSound.tripleChimePlay
        }
        
        if let restSoundRawValue = UserDefaults.standard.object(forKey: "restSound") as? UInt32,
           let restSoundValue = SoundPlayer.SystemSound(rawValue: restSoundRawValue) {
            self.restSound = restSoundValue
        } else {
            UserDefaults.standard.set(SoundPlayer.SystemSound.tripleChimePause.rawValue, forKey: "restSound")
            self.restSound = SoundPlayer.SystemSound.tripleChimePause
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

        if let measurementSystemRawValue = UserDefaults.standard.string(forKey: "measurementSystem"),
            let measurementSystemValue = MeasurementSystem(rawValue: measurementSystemRawValue) {
            self.measurementSystem = measurementSystemValue
        } else {
            UserDefaults.standard.set(MeasurementSystem.metric.rawValue, forKey: "measurementSystem")
            self.measurementSystem = MeasurementSystem.metric
        }

        if let appDisplayModeRawValue = UserDefaults.standard.string(forKey: "appDisplayMode"),
            let appDisplayModeValue = AppColorScheme(rawValue: appDisplayModeRawValue) {
            self.appDisplayMode = appDisplayModeValue
        } else {
            UserDefaults.standard.set(AppColorScheme.dark.rawValue, forKey: "appDisplayMode")
            self.appDisplayMode = AppColorScheme.dark
        }
    }
}

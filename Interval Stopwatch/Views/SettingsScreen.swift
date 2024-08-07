
//
//  Settings.swift
//  Interval Stopwatch
//
//  Created by Dimitri Cunning on 12/03/2024.
//

import SwiftUI

struct ViewSettings: View {
    @ObservedObject var settings: Settings
    @Binding var isPresented: Bool
    @ObservedObject var stopwatch: Stopwatch
    @ObservedObject var cycle: Cycle
    @ObservedObject var firstInterval: Interval
    @ObservedObject var secondInterval: Interval

    var body: some View {
        NavigationView {
            Form {
                SoundSettingsSection(
                    settings: settings,
                    stopwatch: stopwatch,
                    firstInterval: firstInterval,
                    secondInterval: secondInterval
                )
                ColorSettingsSection(
                    settings: settings,
                    cycle: cycle,
                    firstInterval: firstInterval,
                    secondInterval: secondInterval
                )
                AppAppearanceSettingsSection(
                    settings: settings,
                    stopwatch: stopwatch
                )
                MeasurementSettingsSection(
                    settings: settings
                )
                EmailFeedbackSettingsSection()
            }
            .navigationBarTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                isPresented = false
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(settings.appDisplayMode == AppColorScheme.system ? ColorScheme(.unspecified) : settings.appDisplayMode == AppColorScheme.dark ? .dark : .light)
    }
}

struct SoundSettingsSection: View {
    @ObservedObject var settings: Settings
    @ObservedObject var stopwatch: Stopwatch
    @ObservedObject var firstInterval: Interval
    @ObservedObject var secondInterval: Interval
    let allSoundsOrdered: [SoundPlayer.SystemSound] = [SoundPlayer.SystemSound.off] + SoundPlayer.SystemSound.allCases.filter { $0 != .off }.sorted(by: { $0.displayName < $1.displayName })

    var body: some View {
        Section(header: Text("Sounds")) {
            Toggle("All sounds", isOn: $settings.soundEnabled).onChange(of: settings.soundEnabled) { oldValue, newValue in
                settings.soundEnabled = newValue
            }
            
            Picker("Active sound", selection: $firstInterval.sound) {
                ForEach(allSoundsOrdered, id: \.self) { sound in
                    Text(sound.displayName).tag(sound)
                }
            }.pickerStyle(DefaultPickerStyle())
            .onChange(of: firstInterval.sound) { oldValue, newValue in
                SoundPlayer.playSound(newValue)
                settings.activeSound = newValue
            }
            
            Picker("Rest sound", selection: $secondInterval.sound) {
                ForEach(allSoundsOrdered, id: \.self) { sound in
                    Text(sound.displayName).tag(sound)
                }
            }.pickerStyle(DefaultPickerStyle())
            .onChange(of: secondInterval.sound) { oldValue, newValue in
                SoundPlayer.playSound(newValue)
                settings.restSound = newValue
            }
            
            Picker("End sound", selection: $stopwatch.endSound) {
                ForEach(allSoundsOrdered, id: \.self) { sound in
                    Text(sound.displayName).tag(sound)
                }
            }.pickerStyle(DefaultPickerStyle())
            .onChange(of: stopwatch.endSound) { oldValue, newValue in
                SoundPlayer.playSound(newValue)
                settings.endSound = newValue
            }
        }
    }
}

struct AppAppearanceSettingsSection: View {
    @ObservedObject var settings: Settings
    @ObservedObject var stopwatch: Stopwatch

    var body: some View {
        Section(header: Text("App Appearance")) {
            Toggle("Show end lines", isOn: $stopwatch.showEndLines).onChange(of: stopwatch.showEndLines) { oldValue, newValue in
                settings.showEndLines = newValue
            }
            
            Picker("Display mode", selection: $settings.appDisplayMode) {
                ForEach(AppColorScheme.allCases) { scheme in
                    Text(scheme.displayName).tag(scheme)
                }
            }.pickerStyle(DefaultPickerStyle()).onChange(of: settings.appDisplayMode) {
                oldValue, newValue in
                settings.appDisplayMode = newValue
            }
        }
    }
}

struct ColorSettingsSection: View {
    @ObservedObject var settings: Settings
    @ObservedObject var cycle: Cycle
    @ObservedObject var firstInterval: Interval
    @ObservedObject var secondInterval: Interval

    var body: some View {
        Section(header: Text("Colours")) {
            Picker("Active colour", selection: $firstInterval.color) {
                ForEach(ColorSelection.allCases, id: \.self) { color in
                    Text(color.displayName).foregroundColor(color.color).tag(color)
                }
            }.pickerStyle(DefaultPickerStyle())
            .onChange(of: firstInterval.color) { oldValue, newValue in
                settings.activeColor = newValue
            }

            Picker("Rest colour", selection: $secondInterval.color) {
                ForEach(ColorSelection.allCases, id: \.self) { color in
                    Text(color.displayName).foregroundColor(color.color).tag(color)
                }
            }.pickerStyle(DefaultPickerStyle())
            .onChange(of: secondInterval.color) { oldValue, newValue in
                settings.restColor = newValue
            }
            
            Picker("Count colour", selection: $cycle.color) {
                ForEach(ColorSelection.allCases, id: \.self) { color in
                    Text(color.displayName).foregroundColor(color.color).tag(color)
                }
            }.pickerStyle(DefaultPickerStyle())
            .onChange(of: cycle.color) { oldValue, newValue in
                settings.countColor = newValue
            }
        }
    }
}

struct MeasurementSettingsSection: View {
    @ObservedObject var settings: Settings
    
    var body: some View {
        Section(header: Text("Measurements")) {
            Picker("Measurement System", selection: $settings.measurementSystem) {
                Text(MeasurementSystem.metric.displayName).tag(MeasurementSystem.metric)
                Text(MeasurementSystem.imperial.displayName).tag(MeasurementSystem.imperial)
            }.pickerStyle(DefaultPickerStyle()).onChange(of: settings.measurementSystem) {
                oldValue, newValue in
                settings.measurementSystem = newValue
            }
        }
    }
}

struct EmailFeedbackSettingsSection: View {
    @State var showingOpenEmailConfirmation: Bool = false
    
    var body: some View {
        Section(header: Text("Feedback")) {
            Section {
                Button(action: {
                    showingOpenEmailConfirmation = true
                }) {
                    Text("Contact us")
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .center)
                }.confirmationDialog(
                    "Report a bug, give feedback or make a feature suggestion via email",
                    isPresented: $showingOpenEmailConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Open", role: .none) {
                        draftEmail()
                        showingOpenEmailConfirmation = false
                    }
                    Button("Cancel", role: .cancel) {
                        showingOpenEmailConfirmation = false
                    }
                }
            }
        }
    }
    
    private func draftEmail() {
        guard let url = URL(string: "mailto:intervals.app@gmail.com?subject=BUG/FEEDBACK/FEATURE&body=") else {
            return
        }
        UIApplication.shared.open(url)
    }
}

//
//  AppTabsController.swift
//  Interval Stopwatch
//
//  Created by Dimitri Cunning on 16/03/2024.
//

import SwiftUI
import SQLite3

struct ContentView: View {
    @ObservedObject var mySettings: Settings = Settings()
    
    var body: some View {
        
        ZStack {
            TabView(selection: $mySettings.tabSelectedValue) {
                ViewStopwatchMain(settings: mySettings)
                    .tabItem {
                        Image(systemName: "stopwatch").environment(\.symbolVariants, .none)
                        Text("Stopwatch")
                    }.tag(1)
                
                ListWorkoutsView(settings: mySettings)
                    .tabItem {
                        Image(systemName: "figure.run")
                        Text("Workouts")
                    }.tag(2)
            }
            .onAppear() {
                let standardAppearance = UITabBarAppearance()
                standardAppearance.backgroundColor = UIColor.clear
                standardAppearance.shadowColor = UIColor.clear
                UITabBar.appearance().standardAppearance = standardAppearance
            }
        }
    }
}

//
//  ClockFaceDisplay.swift
//  Interval Stopwatch
//
//  Created by Dimitri Cunning on 07/03/2024.
//

import SwiftUI

struct ViewInputTimeInterval: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var interval: Interval
    @ObservedObject var settings: Settings
    @State private var selectedMinutes: Int
    @State private var selectedSeconds: Int
    var height: CGFloat
    var width: CGFloat
    var border: CGFloat
    
    init(interval: Interval, settings: Settings, height: CGFloat, width: CGFloat, border: CGFloat) {
        self.interval = interval
        self.settings = settings
        self.height = height
        self.width = width
        self.border = border
        _selectedMinutes = State(initialValue: Int(interval.duration) / 60)
        _selectedSeconds = State(initialValue: Int(interval.duration) % 60)
    }
    
    var body: some View {
        let textColor: Color = colorScheme == .dark ? .white : .black
        VStack(alignment: .center) {
            HStack(spacing: 0) {
                Spacer().frame(width: border)
                
                Text(interval.name)
                    .font(.system(size: 20))
                    .frame(width: border*7.5, alignment: .leading)
                
                ZStack(alignment: .leading) {
                    Picker(
                        selection: $selectedMinutes,
                        label: Text("Minutes").foregroundColor(textColor),
                        content: {
                            ForEach(0..<60) { min in
                                Text(String(format: "%2d", min)).tag(min).foregroundColor(interval.color.color).offset(x: -width/25, y: 0)
                            }
                        }
                    )
                    .pickerStyle(WheelPickerStyle())
                    .scaleEffect(1.2).frame(width: border*5, alignment: .trailing)
                    
                    Text("min")
                        .foregroundColor(textColor).font(.system(size: 20))
                        .offset(x: width/7.5, y: 0)
                }
                
                Spacer().frame(width: border/2)
                
                ZStack(alignment: .leading) {
                    Picker(
                        selection: $selectedSeconds,
                        label: Text("Seconds").foregroundColor(textColor),
                        content: {
                            ForEach(0..<60 / 5) { index in
                                let second = index * 5
                                Text(String(format: "%2d", second)).tag(second).foregroundColor(interval.color.color)
                                    .offset(x: -width/25, y: 0)
                            }
                        }
                    )
                    .pickerStyle(WheelPickerStyle())
                    .scaleEffect(1.2).frame(width: border*5, alignment: .trailing)
                    
                    Text("sec")
                        .foregroundColor(textColor).font(.system(size: 20))
                        .offset(x: width/7.5, y: 0)
                }
                
                Spacer().frame(width: border)
            }
        }
        .frame(minHeight: height*9/10, maxHeight: height)
        .onChange(of: selectedMinutes) { updateIntervalTime() }
        .onChange(of: selectedSeconds) { updateIntervalTime() }
    }
    
    
    private func updateIntervalTime() {
        interval.duration = TimeInterval(selectedMinutes * 60 + selectedSeconds)
    }
    
}


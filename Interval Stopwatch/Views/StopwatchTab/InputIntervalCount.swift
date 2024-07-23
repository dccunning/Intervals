//
//  InputCount.swift
//  Interval Stopwatch
//
//  Created by Dimitri Cunning on 13/03/2024.
//

import SwiftUI

struct ViewInputIntervalCount: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var cycle: Cycle
    @ObservedObject var settings: Settings
    var height: CGFloat
    var width: CGFloat
    var border: CGFloat
    
    init(cycle: Cycle, settings: Settings, height: CGFloat, width: CGFloat, border: CGFloat) {
        self.cycle = cycle
        self.settings = settings
        self.height = height
        self.width = width
        self.border = border
    }
    
    var body: some View {
        let textColor: Color = colorScheme == .dark ? .white : .black
        VStack(alignment: .center) {
            HStack(spacing: 0) {
                Spacer().frame(width: border)
                
                Text("Intervals")
                    .font(.system(size: 20))
                    .frame(width: border*7.5, alignment: .leading)
                
                Picker(
                    selection: $cycle.selectedCount,
                    label: Text("Intervals").foregroundColor(textColor),
                    content: {
                        Text("∞").tag(0).foregroundColor(cycle.color.color)
                        ForEach(Array(1..<cycle.maxNumber + 1), id: \.self) { count in
                            Text("\(count)").tag(count)
                                .foregroundColor(cycle.color.color)
                        }
                    }
                )
                .pickerStyle(WheelPickerStyle())
                .scaleEffect(1.2).frame(width: border*3.5, alignment: .trailing)
                
                Spacer()
            }
        }
        .frame(minHeight: height*9/10, maxHeight: height)
    }
}




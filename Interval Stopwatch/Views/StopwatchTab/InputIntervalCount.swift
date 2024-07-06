//
//  InputCount.swift
//  Interval Stopwatch
//
//  Created by Dimitri Cunning on 13/03/2024.
//

import SwiftUI

struct ViewInputIntervalCount: View {
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
        VStack(alignment: .center) {
            HStack(spacing: 0) {
                Spacer().frame(width: border)
                Text("Intervals")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if settings.pickerStyle == "Drop down" {
                    Picker(
                        selection: $cycle.selectedCount,
                        label: Text("Intervals"),
                        content: {
                            Text("∞").tag(0).foregroundColor(cycle.color.color)
                            ForEach(Array(1..<cycle.maxNumber + 1), id: \.self) { count in
                                Text("\(count)").tag(count).foregroundColor(cycle.color.color)
                            }
                        }
                    )
                    .pickerStyle(DefaultPickerStyle())
                    .scaleEffect(1.2).frame(minWidth: width/6, maxWidth: width/6, alignment: .trailing)
                } else {
                    Picker(
                        selection: $cycle.selectedCount,
                        label: Text("Intervals"),
                        content: {
                            Text("∞").tag(0).foregroundColor(cycle.color.color)
                            ForEach(Array(1..<cycle.maxNumber + 1), id: \.self) { count in
                                Text("\(count)").tag(count).foregroundColor(cycle.color.color)
                            }
                        }
                    )
                    .pickerStyle(WheelPickerStyle())
                    .scaleEffect(1.2).frame(minWidth: width/6, maxWidth: width/6, alignment: .trailing)
                }

                
                Text("min").foregroundColor(.white).font(.system(size: 20)).hidden()
                Spacer().frame(width: width/6)
                Text("sec").foregroundColor(.white).font(.system(size: 20)).hidden()
                Spacer().frame(width: border)
            }.frame(maxWidth: .infinity).background(Color.black)
        }.frame(height: height)
    }
}

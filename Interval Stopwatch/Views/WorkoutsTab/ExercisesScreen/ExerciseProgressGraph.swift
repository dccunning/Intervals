//
//  ExerciseProgressGraph.swift
//  Interval Stopwatch
//
//  Created by Dimitri Cunning on 19/07/2024.
//

import SwiftUI
import Charts

enum MetricViewOption: String, CaseIterable, Identifiable {
    case weight = "Weight"
    case volume = "Volume"
    case totalReps = "Reps"
    case activeTime = "Time"
    
    var id: String { self.rawValue }
    
    var unit: String {
        switch self {
        case .weight: return "weight"
        case .volume: return "weight"
        case .totalReps: return "reps"
        case .activeTime: return ""
        }
    }
}

struct ExerciseProgressGraphView: View {
    @ObservedObject var settings: Settings
    @State private var selectedOption: MetricViewOption = .weight
    let exercisesCompleted: [ExercisesCompleted]
    @State private var scaler: Double = 1
    private let numberOfXAxisMarks = 5
    
    private var dateRange: ClosedRange<Date>? {
        guard let minDate = exercisesCompleted.map({ $0.markedForDate }).min(),
              let maxDate = exercisesCompleted.map({ $0.markedForDate }).max()
        else {
            return nil
        }
        return minDate...maxDate
    }
    
    private var availableOptions: [MetricViewOption] {
        var options = MetricViewOption.allCases
        if !exercisesCompleted.contains(where: { $0.durationMinutes > 0 || $0.durationSeconds > 0 }) {
            options.removeAll { $0 == .activeTime }
        }
        if !exercisesCompleted.contains(where: { $0.gymWeightUnits > 0 }) {
            options.removeAll { $0 == .weight }
            options.removeAll { $0 == .volume }
        }
        if !exercisesCompleted.contains(where: { $0.reps > 0 || $0.sets > 0}) {
            options.removeAll { $0 == .totalReps }
        }
        return options
    }
    
    private var yAxisRange: ClosedRange<Double> {
        let values = exercisesCompleted.map { calculateValue($0) }
        guard let minValue = values.min(), let maxValue = values.max() else {
            return 0...100 // Default range if there's no data
        }
        
        let padding = (maxValue - minValue) * scaler
        return (max(minValue - padding, 0))...(maxValue + padding)
    }
    
    var body: some View {
        VStack {
            Picker("View Option", selection: $selectedOption) {
                ForEach(availableOptions) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .onChange(of: availableOptions) { oldOption, newOption in
                if !newOption.contains(selectedOption) {
                    selectedOption = newOption.first ?? .weight
                }
            }
            
            HStack(spacing: 0) {
                // Vertical slider for scaler
                VStack {
                    Slider(value: $scaler, in: 0.0...3.0, step: 0.05) {
                        Text("Scale")
                    }
                    .rotationEffect(.degrees(-90))
                    .frame(width: 150)
                    .offset(x: -15)
                }
                .frame(width: 15)
                
                // Chart
                Chart(exercisesCompleted) { exercise in
                    LineMark(
                        x: .value("Date", exercise.markedForDate),
                        y: .value(selectedOption.rawValue, calculateValue(exercise))
                    )
                    PointMark(
                        x: .value("Date", exercise.markedForDate),
                        y: .value(selectedOption.rawValue, calculateValue(exercise))
                    )
                }
                .chartXAxis {
                    AxisMarks(preset: .aligned, values: .stride(by: .day)) { value in
                        if let date = value.as(Date.self),
                           let range = dateRange,
                           isDateIncluded(date, in: range) {
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        if let doubleValue = value.as(Double.self) {
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel {
                                if selectedOption == .activeTime {
                                    Text(formatTime(seconds: Int(doubleValue)))
                                } else if (selectedOption == .weight || selectedOption == .volume) {
                                    Text("\(String(format: "%g", doubleValue)) \(settings.measurementSystem.shortForm)")
                                } else {
                                    Text("\(String(format: "%g", doubleValue)) \(selectedOption.unit)")
                                }
                            }
                        }
                    }
                }
                .chartYScale(domain: yAxisRange)
                .frame(height: 150)
            }
            .padding()
        }
    }
    
    private func isDateIncluded(_ date: Date, in range: ClosedRange<Date>) -> Bool {
        guard let start = range.lowerBound.startOfDay,
              let end = range.upperBound.startOfDay,
              numberOfXAxisMarks > 1 else { return false }

        let interval = end.timeIntervalSince(start) / Double(numberOfXAxisMarks - 1)
        let dates = stride(from: start, through: end, by: interval).map { $0 }
        return dates.contains { Calendar.current.isDate($0, inSameDayAs: date) }
    }
    
    private func calculateValue(_ exercise: ExercisesCompleted) -> Double {
        let multiplier: Double = settings.measurementSystem.multiplier
        switch selectedOption {
        case .weight:
            return Double(exercise.gymWeightUnits) * multiplier
        case .volume:
            if exercise.reps > 0 && exercise.sets == 0 {
                return Double(exercise.gymWeightUnits * exercise.reps) * multiplier
            } else if exercise.sets > 0 && exercise.reps == 0 {
                return Double(exercise.gymWeightUnits * exercise.sets) * multiplier
            } else if exercise.sets == 0 && exercise.reps == 0 {
                return Double(exercise.gymWeightUnits) * multiplier
            } else {
                return Double(exercise.gymWeightUnits * exercise.sets * exercise.reps) * multiplier
            }
            
        case .totalReps:
            return Double(exercise.reps * exercise.sets)
        case .activeTime:
            let totalSeconds = (exercise.durationMinutes * 60 + exercise.durationSeconds)
            return Double(totalSeconds)
        }
    }
    
    private func formatTime(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = seconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, remainingSeconds)
        } else {
            return String(format: "%d:%02d", minutes, remainingSeconds)
        }
    }
}

extension Date {
    var startOfDay: Date? {
        return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)
    }
}

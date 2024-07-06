//
//  WorkoutActionDisplay.swift
//  Interval Stopwatch
//
//  Created by Dimitri Cunning on 08/05/2024.
//

import SwiftUI

struct WorkoutActionDisplay: View {
    @Binding var workouts: [Workout]
    @Binding var workoutsCompletedList: [WorkoutsCompleted]
    var border: CGFloat
    @Binding var currentSelectedDate: Date
    var index: Int
    var cornerRadius: CGFloat

    
    init(workouts: Binding<[Workout]>, workoutsCompletedList: Binding<[WorkoutsCompleted]>,
         border: CGFloat, currentSelectedDate: Binding<Date>, index: Int, cornerRadius: CGFloat) {
        self._workouts = workouts
        self._workoutsCompletedList = workoutsCompletedList
        self.border = border
        self._currentSelectedDate = currentSelectedDate
        self.index = index
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        SwipeAction(cornerRadius: cornerRadius, direction: .leading) {
            WorkoutPreview(workout: self.$workouts[index], border: border)
        } actions: {
            Action(workoutId: workouts[index].id, date: currentSelectedDate) {
                if DataBase().toggleOrInsertWorkoutCompletedTableRow(workoutId: workouts[index].id, markedForDate: currentSelectedDate) {
                } else {
                    print("Error executing toggle/insert query")
                }
                workouts[index].lastCompletedTimestamp = DataBase().updateWorkoutLastCompletedTimestamp(workoutId: workouts[index].id)
                workouts = DataBase().fetchWorkoutTableRows()
                
                updateWorkoutsSelected()
            }
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .buttonStyle(PlainButtonStyle())

    }
    
    func updateWorkoutsSelected() {
        let dateWithTimeZone: Date = Calendar.current.startOfDay(for: Date()).addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT(for: Date())))
        let dateSince = Calendar.current.date(byAdding: .day, value: -14, to: dateWithTimeZone) ?? dateWithTimeZone
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let formattedDateSince = dateFormatter.string(from: dateSince)
        workoutsCompletedList = DataBase().fetchWorkoutsCompletedTableRows(dateSince: formattedDateSince)
    }
}


// Custom swipe action view
struct SwipeAction<Content: View>: View {
    var cornerRadius: CGFloat = 0
    var direction: SwipeDirection = .trailing
    
    @ViewBuilder var content: Content
    @ActionBuilder var actions: [Action]
    
    let viewID = UUID()
    @State private var isEnabled: Bool = true
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    content
                        .rotationEffect(.init(degrees: direction == .leading ? -180 : 0))
                        .containerRelativeFrame(.horizontal)
                        .background {
                            if let firstAction = actions.first {
                                ZStack {
                                    Rectangle().fill(firstAction.tint)
                                    Rectangle().fill(.gray).cornerRadius(cornerRadius)
                                }
                            }
                        }
                        .id(viewID)
                        .transition(/*@START_MENU_TOKEN@*/.identity/*@END_MENU_TOKEN@*/)
                    
                    ActionButtons {
                        withAnimation(.snappy) {
                            scrollProxy.scrollTo(viewID, anchor: direction == .trailing ? .topLeading : .topTrailing)
                        }
                    }
                }
                .scrollTargetLayout()
                .visualEffect { content, geometryProxy in
                    content
                        .offset(x: scrollOffset(geometryProxy))
                }
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .background {
                if let lastAction = actions.last  {
                    Rectangle()
                        .fill(lastAction.tint)
                }
            }
            .clipShape(.rect(cornerRadius: cornerRadius))
            .rotationEffect(.init(degrees: direction == .leading ? 180 : 0))
        }
        .allowsHitTesting(isEnabled)
        .transition(CustomTransition())
    }
    
    // Action buttons
    @ViewBuilder
    func ActionButtons(resetPosition: @escaping () -> ()) -> some View {
        // Each button with 80 width
        Rectangle()
            .fill(.clear)
            .frame(width: CGFloat(actions.count) * 80)
            .overlay(alignment: direction.alignment) {
                HStack(spacing: 0) {
                    ForEach(actions) { button in
                        Button(action: {
                            Task {
                                isEnabled = false
                                resetPosition()
                                try? await Task.sleep(for: .seconds(0.25))
                                button.action()
                                try? await Task.sleep(for: .seconds(0.1))
                                isEnabled = true
                            }
                        }, label: {
                            Image(systemName: button.icon)
                                .font(button.iconFont)
                                .foregroundStyle(button.iconTint)
                                .frame(width: 80)
                                .frame(maxHeight: .infinity)
                                .contentShape(.rect)
                        })
                        .buttonStyle(.plain)
                        .background(button.tint)
                        .rotationEffect(.init(degrees: direction == .leading ? -180 : 0))
                    }
                }
            }
    }
    
    func scrollOffset(_ proxy: GeometryProxy) -> CGFloat {
        let minX = proxy.frame(in: .scrollView(axis: .horizontal)).minX
        return (minX > 0 ? -minX : 0)
    }
}

// Custom transition
struct CustomTransition: Transition {
    func body(content: Content, phase: TransitionPhase) -> some View {
        content.mask {
            GeometryReader {
                let size = $0.size
                
                Rectangle()
                    .offset(y: phase == .identity ? 0 : -size.height)
            }
            .containerRelativeFrame(.horizontal)
        }
    }
}

// Swipe direction
enum SwipeDirection {
    case leading
    case trailing
    
    var alignment: Alignment {
        switch self {
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        }
    }
}

// Action model
struct Action: Identifiable {
    private(set) var id: UUID = .init()
    var workoutId: Int
    var date: Date
    var iconFont: Font = .title
    var iconTint: Color = .white
    var isEnabled: Bool = true
    var action: () -> ()
    
    var tint: Color {
        let workoutIsCompleted = DataBase().workoutIsCompletedOnDate(workoutId: workoutId, date: date)
        return workoutIsCompleted ? Color.gray : Color(red: 0, green: 0.5, blue: 0)
    }
    
    var icon: String {
        let workoutIsCompleted = DataBase().workoutIsCompletedOnDate(workoutId: workoutId, date: date)
        return workoutIsCompleted ? "xmark" : "checkmark"
    }
    
    init(workoutId: Int, date: Date, action: @escaping () -> ()) {
        self.workoutId = workoutId
        self.date = date
        self.action = action
    }
}

@resultBuilder
struct ActionBuilder {
    static func buildBlock(_ components: Action...) -> [Action] {
        return components
    }
}

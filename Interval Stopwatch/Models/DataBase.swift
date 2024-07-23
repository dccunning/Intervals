//
//  DataBase.swift
//  Interval Stopwatch
//
//  Created by Dimitri Cunning on 02/04/2024.
//

import SwiftUI
import SQLite3

class DataBase {
    var db: OpaquePointer?
    var path: String = "IntervalStopwatch.sqlite"

    init() {
        self.db = openDatabase()
    }
    
    deinit {
        sqlite3_close(self.db)
    }

    func openDatabase() -> OpaquePointer? {
        do {
            let filePath = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(path)

            var db: OpaquePointer? = nil

            if sqlite3_open(filePath.path, &db) != SQLITE_OK {
                print("error opening or creating db")
                return nil
            } else {
                return db
            }
        } catch {
            print("Error opening or creating database: \(error)")
            return nil
        }
    }

    func selectQuery(_ query: String) -> [[Any]]? {
        var queryStatement: OpaquePointer?
        var results: [[Any]] = []

        // Prepare the query
        if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {

            // Fetch rows
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                var row: [Any] = []
                let columnCount = sqlite3_column_count(queryStatement)
                for i in 0..<columnCount {
                    let columnType = sqlite3_column_type(queryStatement, i)

                    switch columnType {
                    case SQLITE_INTEGER:
                        let value = sqlite3_column_int(queryStatement, i)
                        row.append(Int(value))
                    case SQLITE_FLOAT:
                        let value = sqlite3_column_double(queryStatement, i)
                        row.append(Double(value))
                    case SQLITE_TEXT:
                        let value = String(cString: sqlite3_column_text(queryStatement, i))
                        row.append(value)
                    case SQLITE_NULL:
                        row.append("nil")
                    default:
                        row.append("Unknown column type")
                    }
                }
                results.append(row)
            }
        } else {
            print("Query could not be prepared")
        }

        // Finalize the query statement
        sqlite3_finalize(queryStatement)
        return results.isEmpty ? nil : results
    }

    func execute(query: String) -> Bool {
        var statement: OpaquePointer?
        
        // Prepare the SQL statement
        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("Error preparing statement: \(errorMessage)")
            return false
        }
        
        // Execute the SQL statement
        let result = sqlite3_step(statement)
        if result != SQLITE_DONE {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("Error executing statement: \(errorMessage)")
            sqlite3_finalize(statement)
            return false
        }
        
        sqlite3_finalize(statement)
        return true
    }
    
    func createWorkoutTable(){
        let createTableQuery = """
        CREATE TABLE IF NOT EXISTS Workouts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            workoutIndex INTEGER,
            name TEXT,
            durationMinutes INTEGER,
            color TEXT,
            chunkSize INTEGER,
            LastCompletedTimestamp TIMESTAMP
        );
        """
        if self.execute(query: createTableQuery) {
        } else {
            print("Error creating Workouts table.")
        }
    }
    
    func insertWorkoutTableRow(name: String, hours: Int, minutes: Int, selectedColor: ColorSelection, chunkSize: Int) -> Bool {
        let insertQuery = "INSERT INTO Workouts (name, durationMinutes, color, chunkSize) VALUES ('\(name)', \(Int(hours * 60 + minutes)), '\(selectedColor.displayName)', \(chunkSize))"
        return self.execute(query: insertQuery)
    }
    
    func fetchWorkoutTableRows() -> [Workout] {
        var workouts: [Workout] = []

        let query = "SELECT id, name, durationMinutes, color, chunkSize, LastCompletedTimestamp FROM Workouts ORDER BY workoutIndex IS NULL, workoutIndex ASC, id ASC;"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let name = String(cString: sqlite3_column_text(statement, 1))
                let durationMinutes = Int(sqlite3_column_int(statement, 2))
                let color = String(cString: sqlite3_column_text(statement, 3))
                let chunkSize = Int(sqlite3_column_int(statement, 4))
                
                var lastCompletedTimestamp: Date?
                if let timestampCString = sqlite3_column_text(statement, 5) {
                    let timestampString = String(cString: timestampCString)
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeZone = TimeZone(identifier: "UTC")
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    if let date = dateFormatter.date(from: timestampString) {
                        lastCompletedTimestamp = date
                    } else {
                        lastCompletedTimestamp = nil
                    }
                } else {
                    lastCompletedTimestamp = nil
                }

                let workout = Workout(id: id, name: name, durationMinutes: durationMinutes, color: color, chunkSize: chunkSize, lastCompletedTimestamp: lastCompletedTimestamp)
                workouts.append(workout)
            }
            sqlite3_finalize(statement)
        } else {
            print("Error preparing query: fetchWorkoutTableRows")
        }

        return workouts
    }
    
    func updateWorkoutIndexes(workouts: [Workout]) -> Bool {
        let mapworkoutIndexChange: [(workoutId: Int, workoutIndex: Int)] = workouts.enumerated().map { (index, workout) in
            return (workout.id, index)
        }
        
        for (workoutId, workoutIndex) in mapworkoutIndexChange {
            let query = "UPDATE Workouts SET workoutIndex = \(workoutIndex) WHERE id = \(workoutId);"

            if self.execute(query: query) {
                continue
            } else {
                print("Error updating workout with id \(workoutId)")
                return false
            }
        }
        return true
    }
    
    func createWorkoutsCompletedTable() {
        let createTableQuery = """
        CREATE TABLE IF NOT EXISTS WorkoutsCompleted (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            workoutId INTEGER,
            markedForDate TIMESTAMP,
            completed BOOL,
            updatedTimestamp TIMESTAMP,
            UNIQUE(markedForDate, workoutId)
        );
        """
        
        if self.execute(query: createTableQuery) {
        } else {
            print("Error creating WorkoutsCompleted table.")
        }
    }
    
    func toggleOrInsertWorkoutCompletedTableRow(workoutId: Int, markedForDate: Date, setAsComplete: Bool = false) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateTimeFormatter.timeZone = TimeZone(identifier: "UTC")
        let updatedTimestamp = dateTimeFormatter.string(from: Date())
        let formattedDate = dateFormatter.string(from: markedForDate)
        
        // Check if the row exists
        let checkQuery = """
        SELECT id, completed
        FROM WorkoutsCompleted
        WHERE workoutId = \(workoutId) AND markedForDate = '\(formattedDate)';
        """
        
        if let result = selectQuery(checkQuery), !result.isEmpty, !result[0].isEmpty {
            if let firstRow = result.first, result.count > 0 {
                let currentCompleted = firstRow[1] as? Int == 1
                let toggleCompleted = !currentCompleted || setAsComplete

                let updateQuery = """
                UPDATE WorkoutsCompleted
                SET completed = \(toggleCompleted ? 1 : 0), updatedTimestamp = '\(updatedTimestamp)'
                WHERE workoutId = \(workoutId) AND markedForDate = '\(formattedDate)';
                """
                return self.execute(query: updateQuery)
            } else {
                print("Incorrect result data")
                return false
            }
        } else {
            let insertQuery = """
            INSERT INTO WorkoutsCompleted (workoutId, markedForDate, completed, updatedTimestamp)
            VALUES (\(workoutId), '\(formattedDate)', 1, '\(updatedTimestamp)');
            """
            return self.execute(query: insertQuery)
        }
    }
    
    func workoutIsCompletedOnDate(workoutId: Int, date: Date) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let formattedDate = dateFormatter.string(from: date)
        let query = """
        SELECT id
        FROM WorkoutsCompleted
        WHERE workoutId = \(workoutId) AND markedForDate = '\(formattedDate)' AND completed;
        """
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            let result = sqlite3_step(statement)

            if result == SQLITE_ROW {
                sqlite3_finalize(statement)
                return true
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(self.db))
            print("Error preparing query: workoutIsCompletedOnDate - \(errorMessage)")
        }

        sqlite3_finalize(statement)
        return false
    }
    
    func fetchWorkoutsCompletedTableRows(condition: String = "", dateSince: String) -> [WorkoutsCompleted] {
        var markedWorkoutsCompleted: [WorkoutsCompleted] = []

        let query = """
        SELECT wc.id, wc.workoutId, wc.markedForDate, wc.completed, w.color, w.chunkSize, (julianday(wc.markedForDate) - julianday(strftime('%Y-%m-%d', 'now', 'localtime')) + 14) AS indexDate, strftime('%Y-%m-%d %H:%M:%S', 'now', 'localtime') as currentDatetime, wc.updatedTimestamp
        FROM WorkoutsCompleted wc
        JOIN Workouts w ON wc.workoutId = w.id 
        WHERE markedForDate > '\(dateSince)' AND completed
        ORDER BY wc.updatedTimestamp DESC;
        """

        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let dateFormatter = DateFormatter()
                let dateTimeFormatter = DateFormatter()
                dateTimeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                dateTimeFormatter.timeZone = TimeZone(identifier: "UTC")
                dateFormatter.dateFormat = "yyyy-MM-dd"
                dateFormatter.timeZone = TimeZone(identifier: "UTC")
                
                let id = Int(sqlite3_column_int(statement, 0))
                let workoutId = Int(sqlite3_column_int(statement, 1))
                let timestampString = String(cString: sqlite3_column_text(statement, 2))
                let completed = sqlite3_column_int(statement, 3) == 1 ? true : false
                let color = String(cString: sqlite3_column_text(statement, 4)!)
                let chunkSize = Int(sqlite3_column_int(statement, 5))
                let indexDate = Int(sqlite3_column_int(statement, 6))
                let currentDatetime = dateTimeFormatter.date(from: String(cString: sqlite3_column_text(statement, 7)))
                let updatedTimestamp = String(cString: sqlite3_column_text(statement, 8))
                
                if let _ = dateTimeFormatter.date(from: updatedTimestamp) {
                } else {
                    print("Failed to convert string to date: \(updatedTimestamp)")
                }
                
                if let markedForDate = dateFormatter.date(from: timestampString), let updatedTimestamp = dateTimeFormatter.date(from: updatedTimestamp) {
                    let workoutCompleted = WorkoutsCompleted(id: id, workoutId: workoutId, markedForDate: markedForDate, completed: completed, updatedTimestamp: updatedTimestamp, color: color, chunkSize: chunkSize, indexDate: indexDate, currentDatetime: currentDatetime)
                    markedWorkoutsCompleted.append(workoutCompleted)
                } else {
                    print("Failed to convert timestamp string to Date (timestampString: \(timestampString)) (updatedTimestamp: \(updatedTimestamp))")
                }
                
            }
            sqlite3_finalize(statement)
        } else {
            print("Error preparing query: fetchWorkoutsCompletedTableRows")
        }
        return markedWorkoutsCompleted
    }
    
    func updateWorkoutLastCompletedTimestamp(workoutId: Int) -> Date? {
        let markedForDate = """
        SELECT max(markedForDate) as date
        FROM WorkoutsCompleted
        WHERE workoutId = \(workoutId) AND completed = 1;
        """
        var updateQuery: String
        
        if let result = DataBase().selectQuery(markedForDate),
           !result.isEmpty,
           !result[0].isEmpty,
           let firstRow = result.first,
           let currentCompleted = firstRow.first as? String {
            updateQuery = """
                UPDATE Workouts
                SET LastCompletedTimestamp = '\(currentCompleted)'
                WHERE id = \(workoutId);
                """
        } else {
            updateQuery = """
                UPDATE Workouts
                SET LastCompletedTimestamp = NULL
                WHERE id = \(workoutId);
                """
        }
        
        if self.execute(query: updateQuery) {
        } else {
            print("Error updating LastCompletedTimestamp")
        }
        
        let query = """
        SELECT LastCompletedTimestamp
        FROM Workouts
        WHERE id = \(workoutId);
        """
        
        if let result = self.selectQuery(query),
              !result.isEmpty,
              !result[0].isEmpty,
              let firstRow = result.first,
           let lastCompletedTimestampString = firstRow.first as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            if let date: Date = dateFormatter.date(from: lastCompletedTimestampString) {
                return date
            }
        }
        return nil
    }
    
    func createExerciseTable() {
        let createTableQuery = """
        CREATE TABLE IF NOT EXISTS Exercises (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            exerciseIndex INTEGER,
            workoutId INTEGER,
            name TEXT,
            gymWeightUnits INTEGER,
            reps INTEGER,
            sets INTEGER,
            durationHours INTEGER,
            durationMinutes INTEGER,
            durationSeconds INTEGER,
            color TEXT,
            notes TEXT
        );
        """
        
        if self.execute(query: createTableQuery) {
        } else {
            print("Error creating Exercises table.")
        }
    }
    
    func fetchExerciseTableRows(workoutId: Int) -> [Exercise] {
        var exercises: [Exercise] = []
        var statement: OpaquePointer?
        let query = "SELECT name, gymWeightUnits, reps, sets, durationHours, durationMinutes, durationSeconds, color, notes, id FROM Exercises WHERE workoutId = \(workoutId) ORDER BY exerciseIndex IS NULL, exerciseIndex ASC, id ASC;"
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let name = String(cString: sqlite3_column_text(statement, 0))
                let gymWeightUnits = Int(sqlite3_column_int(statement, 1))
                let reps = Int(sqlite3_column_int(statement, 2))
                let sets = Int(sqlite3_column_int(statement, 3))
                let durationHours = Int(sqlite3_column_int(statement, 4))
                let durationMinutes = Int(sqlite3_column_int(statement, 5))
                let durationSeconds = Int(sqlite3_column_int(statement, 6))
                let color = String(cString: sqlite3_column_text(statement, 7))
                let notes = String(cString: sqlite3_column_text(statement, 8))
                let id = Int(sqlite3_column_int(statement, 9))

                let exercise = Exercise(id: id, name: name, gymWeightUnits: gymWeightUnits, reps: reps, sets: sets, durationHours: durationHours, durationMinutes: durationMinutes, durationSeconds: durationSeconds, color: color, notes: notes)
                exercises.append(exercise)
            }
            sqlite3_finalize(statement)
        } else {
            print("Error preparing query: fetchExerciseTableRows")
        }

        return exercises
    }
    
    func updateExerciseIndexes(exercises: [Exercise]) -> Bool {
        let mapExerciseIndexChange: [(exerciseId: Int, exerciseIndex: Int)] = exercises.enumerated().map { (index, exercise) in
            return (exercise.id, index)
        }
        
        for (exerciseId, exerciseIndex) in mapExerciseIndexChange {
            let query = "UPDATE Exercises SET exerciseIndex = \(exerciseIndex) WHERE id = \(exerciseId);"

            if self.execute(query: query) {
                continue
            } else {
                print("Error updating exercise with id \(exerciseId)")
                return false
            }
        }
        return true
    }
    
    func insertExerciseTableRow(workoutId: Int, name: String, gymWeightUnits: Int, reps: Int, sets: Int, durationHours: Int, durationMinutes: Int, durationSeconds: Int, color: String, notes: String) -> Bool {
        let insertQuery = "INSERT INTO Exercises (workoutId, name, gymWeightUnits, reps, sets, durationHours, durationMinutes, durationSeconds, color, notes) VALUES (\(workoutId), '\(name)', \(gymWeightUnits), \(reps), \(sets), \(durationHours), \(durationMinutes), \(durationSeconds), '\(color)', '\(notes)');"
        return self.execute(query: insertQuery)
    }
    
    func deleteExercise(exerciseId: Int) -> Bool {
        let deleteQuery: String = "DELETE FROM Exercises WHERE id = \(exerciseId)"
        return self.execute(query: deleteQuery)
    }
    
    func updateExercise(exerciseId: Int, workoutId: Int, name: String, gymWeightUnits: Int, reps: Int, sets: Int, durationHours: Int, durationMinutes: Int, durationSeconds: Int, color: String, notes: String) -> Bool {
        let updateQuery = """
        UPDATE Exercises
        SET workoutId = \(workoutId), name = '\(name)', gymWeightUnits = \(gymWeightUnits), reps = \(reps), sets = \(sets), durationHours = \(durationHours), durationMinutes = \(durationMinutes), durationSeconds = \(durationSeconds), color = '\(color)', notes = '\(notes)'
        WHERE id = \(exerciseId);
        """
        return self.execute(query: updateQuery)
    }
    
    func updateWorkout(workoutId: Int, name: String, durationMinutes: Int, selectedColor: String, chunkSize: Int) -> Bool {
        let updateQuery = """
        UPDATE Workouts
        SET name = '\(name)', durationMinutes = \(durationMinutes), color = '\(selectedColor)', chunkSize = \(chunkSize)
        WHERE id = \(workoutId);
        """
        return self.execute(query: updateQuery)
    }
    
    func deleteWorkout(workoutId: Int) -> Bool {
        let deleteQuery: String = "DELETE FROM Workouts WHERE id = \(workoutId);"
        return self.execute(query: deleteQuery)
    }
    
    func createExercisesCompletedTable() {
        let createTableQuery = """
        CREATE TABLE IF NOT EXISTS ExercisesCompleted (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            exerciseId INTEGER,
            exerciseName TEXT,
            markedForDate TIMESTAMP,
            completed BOOL,
            updatedTimestamp TIMESTAMP,
            gymWeightUnits INTEGER,
            reps INTEGER,
            sets INTEGER,
            durationHours INTEGER,
            durationMinutes INTEGER,
            durationSeconds INTEGER
        );
        """
        
        if self.execute(query: createTableQuery) {
        } else {
            print("Error creating ExercisesCompleted table.")
        }
    }
    
    func insertOrToggleExercisesCompletedRow(exerciseId: Int, exerciseName: String, markedForDate: Date, gymWeightUnits: Int, reps: Int, sets: Int, durationHours: Int, durationMinutes: Int, durationSeconds: Int) -> Bool {
        // Do this every time an exercise is marked: insert
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateTimeFormatter.timeZone = TimeZone(identifier: "UTC")
        let formattedDate = dateFormatter.string(from: markedForDate)
        let updatedTimestamp = dateTimeFormatter.string(from: Date())
        
        // Check if the row exists
        let checkQuery = """
        SELECT id, completed
        FROM ExercisesCompleted
        WHERE exerciseId = \(exerciseId) AND markedForDate = '\(formattedDate)';
        """
        
        if let result = selectQuery(checkQuery), !result.isEmpty, !result[0].isEmpty {
            if let firstRow = result.first, result.count > 0 {
                let currentCompleted = firstRow[1] as? Int == 1
                let toggleCompleted = !currentCompleted

                let updateQuery = """
                UPDATE ExercisesCompleted
                SET completed = \(toggleCompleted ? 1 : 0), updatedTimestamp = '\(updatedTimestamp)', exerciseName = '\(exerciseName)', gymWeightUnits = \(gymWeightUnits), reps = \(reps), sets = \(sets), durationHours = \(durationHours), durationMinutes = \(durationMinutes), durationSeconds = \(durationSeconds)
                WHERE exerciseId = \(exerciseId) AND markedForDate = '\(formattedDate)';
                """

                return self.execute(query: updateQuery)
            } else {
                print("Incorrect result data")
                return false
            }
        } else {
            let insertQuery = """
            INSERT INTO ExercisesCompleted (exerciseId, exerciseName, markedForDate, completed, updatedTimestamp, gymWeightUnits, reps, sets, durationHours, durationMinutes, durationSeconds)
            VALUES (\(exerciseId), '\(exerciseName)', '\(formattedDate)', 1, '\(updatedTimestamp)', \(gymWeightUnits), \(reps), \(sets), \(durationHours), \(durationMinutes), \(durationSeconds));
            """

            return self.execute(query: insertQuery)
        }
    }
    
    func fetchExercisesCompletedHistory(exerciseName: String) -> [ExercisesCompleted] {
        // Get a table of exercises with the given exercise name and return details for each marked date
        let selectQuery = """
        SELECT EC.id, EC.markedForDate, EC.gymWeightUnits, EC.reps, EC.sets, EC.durationHours, EC.durationMinutes, EC.durationSeconds
        FROM ExercisesCompleted EC
        INNER JOIN (
            SELECT markedForDate, MAX(updatedTimestamp) as latestTimestamp
            FROM ExercisesCompleted
            WHERE exerciseName = '\(exerciseName)' AND completed
            GROUP BY markedForDate
        ) Latest ON EC.markedForDate = Latest.markedForDate AND EC.updatedTimestamp = Latest.latestTimestamp
        WHERE EC.exerciseName = '\(exerciseName)' AND completed
        ORDER BY EC.markedForDate DESC
        LIMIT 50;
        """
        var allExercisesCompleted: [ExercisesCompleted] = []
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, selectQuery, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                dateFormatter.timeZone = TimeZone(identifier: "UTC")
                
                let id = Int(sqlite3_column_int(statement, 0))
                let markedForDate = String(cString: sqlite3_column_text(statement, 1))
                let gymWeightUnits = Int(sqlite3_column_int(statement, 2))
                let reps = Int(sqlite3_column_int(statement, 3))
                let sets = Int(sqlite3_column_int(statement, 4))
                let durationHours = Int(sqlite3_column_int(statement, 5))
                let durationMinutes = Int(sqlite3_column_int(statement, 6))
                let durationSeconds = Int(sqlite3_column_int(statement, 7))

                if let markedForDateConverted = dateFormatter.date(from: markedForDate) {
                    let exerciseCompleted = ExercisesCompleted(id: id, markedForDate: markedForDateConverted, gymWeightUnits: gymWeightUnits, reps: reps, sets: sets, durationHours: durationHours, durationMinutes: durationMinutes, durationSeconds: durationSeconds)
                    allExercisesCompleted.append(exerciseCompleted)
                }
            }
            sqlite3_finalize(statement)
        } else {
            print("Error preparing query: fetchExercisesCompletedHistory")
        }

        return allExercisesCompleted
    }
    
    func isExerciseCompleteOnDate(exerciseId: Int, date: Date) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let formattedDate = dateFormatter.string(from: date)

        let query = """
        SELECT id, completed
        FROM ExercisesCompleted
        WHERE exerciseId = \(exerciseId) AND markedForDate = '\(formattedDate)';
        """

        if let result = selectQuery(query), !result.isEmpty, !result[0].isEmpty {
            if let firstRow = result.first, result.count > 0 {
                let currentCompleted = firstRow[1] as? Int == 1
                return currentCompleted
            }
        }
        return false
    }
    
}

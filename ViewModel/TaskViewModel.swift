//
//  TaskViewModel.swift
//  TaskManagementApp
//
//  Created by Dawood Akbar on 30/01/2025.
//

import SwiftUI

/// A view model that manages tasks and dates for the task management app.
///
/// The `TaskViewModel` holds the current day, the filtered tasks for that day, and an array
/// of dates representing the current week. It uses Combine’s `@Published` to automatically
/// update any views that depend on its data.
class TaskViewModel: ObservableObject {
    
    @Published var storedTasks: [Task] = [
        Task(taskTitle: "Meeting", taskDescription: "Discuss team task for the day", taskDate: Date(timeIntervalSince1970: 1738377994)),
        Task(taskTitle: "Icon set", taskDescription: "Edit icons for team tast for next week", taskDate: Date(timeIntervalSince1970: 1738389600)),
        Task(taskTitle: "Prototype", taskDescription: "make and send prototype", taskDate: Date(timeIntervalSince1970: 1738411200)),
        Task(taskTitle: "Check asset", taskDescription: "start checking the assets", taskDate: Date(timeIntervalSince1970: 1738423800)),
        Task(taskTitle: "Team party", taskDescription: "make fun with team mates", taskDate: Date(timeIntervalSince1970: 1735743300)),
        Task(taskTitle: "Client meeting", taskDescription: "Explain project to client", taskDate: Date(timeIntervalSinceNow: 7)),
        Task(taskTitle: "Next Project", taskDescription: "discuss the project with the team", taskDate: Date(timeIntervalSinceNow: 6)),
        Task(taskTitle: "App Proposal", taskDescription: "Meet client for next App Proposal", taskDate: Date(timeIntervalSinceNow: 5)),
    ]
    // Current Week Days
    /// /// The current week dates used to display the week selector.
    ///
    /// This array holds Date objects for the current week. It is calculated in `fetchCurrentWeek()`
    /// and is used to render the week view in the home screen.
    @Published var currentWeek: [Date] = []
    
    // Current Day
    @Published var currentDay: Date = Date()
    
    // Filtering Today Tasks
    @Published var filteredTasks: [Task] = []
    
    // Intializing
    init() {
        fetchCurrentWeek()
        filterTodayTasks()
        
    }
    
    /// Filters tasks scheduled for the current day.
    ///
    /// This method asynchronously filters `storedTasks` to include only tasks
    /// that match `currentDay`, ensuring a smooth UI experience.
    /// The filtering runs on a background thread, and the UI update happens
    /// on the main thread with animation.
    ///
    /// - Note: Ensures UI responsiveness by performing filtering in the background.
    ///         Updates `filteredTasks` on the main thread to avoid UI issues.
    func filterTodayTasks() {
        DispatchQueue.global(qos: .userInteractive).async {
            let calender = Calendar.current
            
            let filtered = self.storedTasks.filter { task in
                return calender.isDate(task.taskDate, inSameDayAs: self.currentDay)
            }
            
            DispatchQueue.main.async {
                withAnimation {
                    self.filteredTasks = filtered
                }
            }
        }
    }
    
    
    
    /// Retrieves and stores the dates for the current week.
    ///
    /// Uses `Calendar.dateInterval(of:for:)` to find the start of the current week
    /// and iterates through the next seven days to populate `currentWeek`.
    ///
    /// - Note: The week starts based on the user's calendar settings.
    func fetchCurrentWeek() {
        let today = Date()
        let calender = Calendar.current
        let week = calender.dateInterval(of: .weekOfMonth, for: today)
        
        guard let firstWeekDay = week?.start else {
            return
        }
        
        (1...7).forEach { day in
            if let weekday = calender.date(byAdding: .day, value: day, to: firstWeekDay){
                currentWeek.append(weekday)
            }
        }
    }
    
    /// Formats a given date into a specified string format.
    ///
    /// Uses `DateFormatter` to convert a `Date` object into a formatted string
    /// based on the provided format.
    ///
    /// - Parameters:
    ///   - date: The `Date` object to be formatted.
    ///   - format: The desired date format as a string (e.g., `"dd/MM/yyyy"`).
    /// - Returns: A formatted date string.
    func extractDate(date: Date, format: String) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    /// Check's is the given date is as the current day
    ///
    /// Uses `Calendar.isDate(_:inSameDayAs:)` to compare the provided date
    /// with `currentDay`.
    ///
    /// - Parameter date: The `Date` to check
    /// - Returns: `true` is the date matches `currentDay`, otherwise `false`
    func isToday(date: Date)-> Bool {
        let calender = Calendar.current
        return calender.isDate(currentDay, inSameDayAs: date)
    }
    
    /// Checks if the given date falls within the current hour.
    ///
    /// Compares the hour component of the provided date with the current system hour
    /// using `Calendar.component(_:from:)`.
    ///
    /// - Parameter date: The `Date` to check.
    /// - Returns: `true` if the date's hour matches the current hour, otherwise `false`.
    func isCurrentHour(date: Date) ->Bool{
        let calender = Calendar.current
        let hour = calender.component(.hour, from: date)
        let currentHour = calender.component(.hour, from: Date())
        
        return hour == currentHour
    }
}

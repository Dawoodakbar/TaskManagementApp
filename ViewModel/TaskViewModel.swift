//
//  TaskViewModel.swift
//  TaskManagementApp
//
//  Created by Dawood Akbar on 30/01/2025.
//

import SwiftUI

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
    
    func extractDate(date: Date, format: String) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    func isToday(date: Date)-> Bool {
        let calender = Calendar.current
        return calender.isDate(currentDay, inSameDayAs: date)
    }
    
    func isCurrentHour(date: Date) ->Bool{
        let calender = Calendar.current
        let hour = calender.component(.hour, from: date)
        let currentHour = calender.component(.hour, from: Date())
        
        return hour == currentHour
    }
}

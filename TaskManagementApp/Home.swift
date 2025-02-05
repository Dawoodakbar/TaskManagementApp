//
//  Home.swift
//  TaskManagementApp
//
//  Created by Dawood Akbar on 30/01/2025.
//

import SwiftUI

/// The main home screen displaying tasks and a weekly calendar.
///
/// This view includes:
/// - A `TaskViewModel` as an `@ObservedObject` to manage task data.
/// - A `Namespace` for smooth animations.
/// - A task list and a horizontally scrollable week selector.
///
/// - The `taskModel` is responsible for handling task-related logic and updates.
/// - The `animation` namespace is used for matched geometry effects.
///
/// - Note: This view relies on `TaskViewModel` to function properly.
struct Home: View {
    
    /// The task view model managing task data and state.
    @ObservedObject var taskModel: TaskViewModel = TaskViewModel()
    
    /// Namespace for animations such as the selected day highlight.
    @Namespace var animation
    
    /// The main view displaying the task manager interface.
    ///
    /// This view contains:
    /// - A horizontally scrollable week view that allows users to select a day.
    /// - A dynamically updating `TasksView` showing tasks for the selected date.
    /// - A pinned `HeaderView` that remains at the top.
    /// - Smooth animations for selecting the current day.
    ///
    /// - The selected day is highlighted using a capsule with a matched geometry effect.
    /// - The current day is visually distinguished with a small white circle.
    ///
    /// - Returns: A `some View` representing the main content.

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            // Lazy Stack with pinned header
            LazyVStack(spacing: 25, pinnedViews: [.sectionHeaders]) {
                Section {
                    
                    // Current week View
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(taskModel.currentWeek, id: \.self){day in
                     
                                VStack(spacing: 10) {
                                    /// EEE will return day as MON, TUE,...etc
                                    Text(taskModel.extractDate(date: day, format: "dd"))
                                        .font(.system(size: 15))
                                        .fontWeight(.semibold)
                                    
                                    Text(taskModel.extractDate(date: day, format: "EEE"))
                                        .font(.system(size: 14))
                                    
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 8, height: 8)
                                        .opacity(taskModel.isToday(date: day) ? 1 : 0)
                                }
                                // ForegroundStyle
                                .foregroundStyle(taskModel.isToday(date: day) ? .primary : .tertiary)
                                .foregroundColor(taskModel.isToday(date: day) ? .white : .black)
                                // Capsule Shape
                                .frame(width: 45, height: 90)
                                .background(
                                    ZStack{
                                        // Matched Geometry Effect
                                        if taskModel.isToday(date: day){
                                            Capsule()
                                                .fill(.black)
                                                .matchedGeometryEffect(id: "CURRENTDAY", in: animation)
                                        }
                                            
                                    }
                                )
                                .contentShape(Capsule())
                                .onTapGesture {
                                    // Updating current Day
                                    withAnimation {
                                        taskModel.currentDay = day
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    TasksView()
                    
                } header: {
                    HeaderView()
                }
            }
        }
        .ignoresSafeArea(.container, edges: .top)
    }


// Tasks View

    
    /// A SwiftUI view that represents a task card.
    ///
    /// This view displays task details, including its title, description, and time.
    /// If the task is scheduled for the current hour, the view highlights it with a different style
    /// and shows team members and a checkmark button.
    ///
    /// - Parameter task: The `Task` model containing the task's information.
    /// - Returns: A `some View` that visually represents the task.
    func TaskCardView(task: Task)-> some View {
        HStack(alignment: .top,spacing: 10) {
            VStack(spacing: 10) {
                Circle()
                    .fill(taskModel.isCurrentHour(date: task.taskDate) ? .black : .clear)
                    .frame(width: 15, height: 15)
                    .background(
                    Circle()
                        .stroke(.black,lineWidth: 1)
                        .padding(-3))
                    .scaleEffect(!taskModel.isCurrentHour(date: task.taskDate) ? 0.8 : 1)
                Rectangle()
                    .fill(.black)
                    .frame(width: 3)
            }
            
            VStack{
                HStack(alignment: .bottom, spacing: 8.0) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(task.taskTitle)
                            .font(.title2.bold())
                            
                        
                        Text(task.taskDescription)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    .hLeading()
                    Text(task.taskDate.formatted(date: .omitted, time: .shortened))
                }
                
                // Team members
                if taskModel.isCurrentHour(date: task.taskDate){
                    HStack(spacing: 0){
                        
                        HStack(spacing: -10) {
                            ForEach(["User1","User2","User3"], id: \.self){user in
                                Image(user)
                                    .resizable()
                                    .aspectRatio( contentMode:  .fill)
                                    .frame(width: 45, height: 45)
                                    .clipShape(Circle())
                                    .background(
                                    Circle()
                                        .stroke(.black, lineWidth: 5)
                                    )
                            }
                        }
                        .hLeading()
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "checkmark")
                                .foregroundColor(.black)
                                .padding(10)
                                .background(Color.white,in: RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding(.top)
                }
               
               
                
            }
            .foregroundColor(taskModel.isCurrentHour(date: task.taskDate) ? .white : .black)
            .frame(maxWidth: .infinity,alignment: .trailing)
            .padding(taskModel.isCurrentHour(date: task.taskDate) ? 15 : 0)
            .padding(.bottom,taskModel.isCurrentHour(date: task.taskDate) ? 0 : 10)
            .background(Color.black

                    .cornerRadius(25)
                    .opacity(taskModel.isCurrentHour(date: task.taskDate) ? 1 : 0)
            )
            
            
        }
        .hLeading()
        .padding(.leading)
    }
    
    /// A SwiftUI view that displays a list of tasks for the selected day.
    ///
    /// This view dynamically updates when the selected date (`currentDay`) changes,
    /// showing a list of tasks using `TaskCardView`. If no tasks are found,
    /// it displays a message. If tasks are still loading, it shows a `ProgressView`.
    ///
    /// - Returns: A `some View` representing the task list.
    func TasksView() -> some View {
        LazyVStack(spacing: 18) {
            if let tasks = taskModel.filteredTasks {
                if tasks.isEmpty {
                    Text("No tasks found!")
                        .font(.system(size: 16))
                        .fontWeight(.light)
                        .offset(y: 100)
                    
                } else {
                    ForEach(tasks){ task in
                        TaskCardView(task: task)
                    }
                }
                
            } else {
                // Progress View
                ProgressView()
                    .offset(y: 80)
            }
        }
        .onChange(of: taskModel.currentDay, perform: { newValue in
            taskModel.filterTodayTasks()
        })
        .padding(.trailing)
    }
    
    /// A SwiftUI view representing the header section.
    ///
    /// The `HeaderView` displays the current date and a title ("Today") on the left side,
    /// while a profile button with a person icon is positioned on the right.
    /// It also accounts for the device’s safe area padding at the top.
    ///
    /// - Returns: A `some View` representing the header.
func HeaderView() -> some View {
    HStack(spacing: 10){
        VStack(alignment: .leading, spacing: 10) {
            Text(Date().formatted(date: .abbreviated, time: .omitted))
                .foregroundColor(.gray)
            Text("Today")
                .font(.largeTitle.bold())
        }
        .hLeading()
        
        Button {
            
        } label: {
            Image(systemName: "person")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 45,height: 45)
                .clipShape(Circle())
        }
    }
    .padding()
    .padding(.top,getSafeArea().top)
    .background(Color.white)
}

}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}

// UI Design Helper functions

extension View {
    /// Aligns the view to the leading edge while taking up the maximum available width.
    ///
    /// This modifier sets the `frame` of the view with a `maxWidth` of `.infinity` and aligns it to the leading edge.
    ///
    /// - Returns: A modified view that is horizontally aligned to the leading
    func hLeading() -> some View {
        self
            .frame(maxWidth: .infinity,alignment: .leading)
    }
    
    /// Aligns the view to trailing edge while taking up the maximum available width
    ///
    ///    /// This modifier sets the `frame` of the view with a `maxWidth` of `.infinity` and aligns it to the trailing edge.
    ///
    /// - Returns: A modified view that is horizontally aligned to the trailing
    func hTrailing() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    /// Centers the view horizontally while taking up the maximum available width.
    ///
    /// This modifier sets the `frame` of the view with a `maxWidth` of `.infinity` and aligns it to the center.
    ///
    /// - Returns: A modified view that is horizontally centered.
    func hCenter() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    /// Retrieves the safe area insets of the current window scene.
    ///
    /// This function attempts to get the safe area insets from the first available `UIWindowScene`
    /// connected to the application. If it fails to retrieve the necessary information, it returns `.zero`.
    ///
    /// - Returns: A `UIEdgeInsets` value representing the safe area insets of the
    func getSafeArea() -> UIEdgeInsets {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        
        guard let safeArea = screen.windows.first?.safeAreaInsets else {
            return .zero
        }
        
        return safeArea
    }
}

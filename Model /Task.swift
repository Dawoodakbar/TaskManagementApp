//
//  Task.swift
//  TaskManagementApp
//
//  Created by Dawood Akbar on 30/01/2025.
//

import SwiftUI

struct Task: Identifiable{
    var id = UUID().uuidString
    var taskTitle: String
    var taskDescription: String
    var taskDate: Date
    
}

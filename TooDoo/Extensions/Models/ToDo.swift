//
//  ToDo.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/16/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import EventKit

extension ToDo {
    
    /// Created to-do.
    
    func created() {
        let eventStore = EKEventStore()
        let reminder = EKReminder(eventStore: eventStore)
        
        if let calendar = eventStore.defaultCalendarForNewReminders() {
            reminder.calendar = calendar
            reminder.title = goal!
            reminder.isCompleted = false
            reminder.notes = note
            
            if let due = due {
                reminder.dueDateComponents = Calendar.current.dateComponents(in: .current, from: due)
            }
            
            do {
                try eventStore.save(reminder, commit: true)
            } catch {
                print("Error trying to save EKReminder")
                print("\(error.localizedDescription)")
            }
        }
    }
    
    /// Set completed attribute.
    
    func complete(completed: Bool) {
        if self.completed != completed {
            self.completed = completed
            completedAt = completed ? Date() : nil
            
            // Handle notifications
            DispatchQueue.main.async {
                if self.completed {
                    NotificationManager.removeTodoReminderNotification(for: self)
                } else {
                    NotificationManager.registerTodoReminderNotification(for: self)
                }
            }
        }
    }
    
    /// Check if is moved to trash.
    
    func isMovedToTrash() -> Bool {
        return movedToTrashAt != nil
    }
    
    /// Set moved to trash attribute to current time.
    
    func moveToTrash() {
        movedToTrashAt = Date()
        // Remove from notifications
        NotificationManager.removeTodoReminderNotification(for: self)
    }
    
    /// Set reminder date.
    
    func setReminder(_ remindDate: Date?) {
        if let remindDate = remindDate {
            remindAt = remindDate
            
            // Register local notification
            DispatchQueue.main.async {
                NotificationManager.registerTodoReminderNotification(for: self)
            }
        } else {
            remindAt = nil
            
            // Remove local notification
            DispatchQueue.main.async {
                NotificationManager.removeTodoReminderNotification(for: self)
            }
        }
    }
    
    /// Get object identifier.
    ///
    /// - Returns: Identifier
    
    func identifier() -> String {
        return objectID.uriRepresentation().relativePath
    }
    
}

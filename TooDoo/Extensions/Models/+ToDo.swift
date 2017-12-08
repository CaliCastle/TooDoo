//
//  +ToDo.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/16/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import EventKit

extension ToDo {
    
    /// The max length limit for goal string.
    ///
    /// - Returns: The max characters limit in integer
    
    open class func goalMaxLimit() -> Int {
        return 70
    }
    
    /// Created to-do.
    
    func created() {
        // Create events if enabled
        createToEvents()
        // Create reminders if enabled
        createToReminders()
    }
    
    /// Create to events with EventKit.
    
    func createToEvents() {
        guard UserDefaultManager.bool(forKey: .CalendarsSync) else { return }
        
        let eventStore = EKEventStore()
        let event = EKEvent(eventStore: eventStore)
        
        if let calendar = eventStore.defaultCalendarForNewEvents {
            event.calendar = calendar
            event.title = goal!
            event.notes = note
            
            if let due = due {
                event.startDate = due
                event.endDate = due
            } else {
                event.startDate = Date()
                event.endDate = Date()
                event.isAllDay = true
            }
            
            do {
                try eventStore.save(event, span: .thisEvent, commit: true)
                // Save event identifier
                eventIdentifier = event.eventIdentifier
            } catch {
                print("Error trying to save EKEvent")
                print("\(error.localizedDescription)")
            }
        }
    }
    
    /// Create to reminders with EventKit.
    
    func createToReminders() {
        guard UserDefaultManager.bool(forKey: .RemindersSync) else { return }
        
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
                // Save reminder identifier
                reminderIdentifier = reminder.calendarItemIdentifier
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
                    // Remove from events
                    self.removeFromEvents()
                    // Set completed to reminders
                    self.setCompletedToReminders(completed: completed)
                } else {
                    NotificationManager.registerTodoReminderNotification(for: self)
                    // Restore to events
                    self.createToEvents()
                    // Set completed to reminders
                    self.setCompletedToReminders(completed: completed)
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
        // Remove from events
        removeFromEvents()
        // Remove from reminders
        removeFromReminders()
        // Remove from notifications
        NotificationManager.removeTodoReminderNotification(for: self)
    }
    
    /// Complete to reminders.
    
    func setCompletedToReminders(completed: Bool) {
        guard UserDefaultManager.bool(forKey: .CalendarsSync), let identifier = reminderIdentifier else { return }
        
        let eventStore = EKEventStore()
        let reminder = eventStore.calendarItem(withIdentifier: identifier)
        
        if let reminder = reminder as? EKReminder {
            reminder.completionDate = completed ? Date() : nil
            reminder.isCompleted = completed
            
            do {
                try eventStore.save(reminder, commit: true)
            } catch {
                print("Error trying to remove a EKEvent")
                print("\(error.localizedDescription)")
            }
        }
    }
    
    /// Remove from events.
    
    func removeFromEvents() {
        guard UserDefaultManager.bool(forKey: .CalendarsSync), let identifier = eventIdentifier else { return }
        
        let eventStore = EKEventStore()
        let event = eventStore.event(withIdentifier: identifier)
        
        if let event = event {
            do {
                try eventStore.remove(event, span: .thisEvent, commit: true)
            } catch {
                print("Error trying to remove a EKEvent")
                print("\(error.localizedDescription)")
            }
        }
    }
    
    /// Remove from reminders.
    
    func removeFromReminders() {
        guard UserDefaultManager.bool(forKey: .RemindersSync), let identifier = reminderIdentifier else { return }
        
        let eventStore = EKEventStore()
        let reminder = eventStore.calendarItem(withIdentifier: identifier)
        
        if let reminder = reminder as? EKReminder {
            do {
                try eventStore.remove(reminder, commit: true)
            } catch {
                print("Error trying to remove a EKEvent")
                print("\(error.localizedDescription)")
            }
        }
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

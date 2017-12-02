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
        // Create events if enabled
        createToEvents()
        // Create reminders if enabled
        createToReminders()
    }
    
    /// Create to events with EventKit.
    
    func createToEvents() {
        guard UserDefaultManager.bool(forKey: .SettingCalendarsSync) else { return }
        
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
        guard UserDefaultManager.bool(forKey: .SettingRemindersSync) else { return }
        
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
        // Remove from events
        removeFromEvents()
        // Remove from reminders
        removeFromReminders()
        // Remove from notifications
        NotificationManager.removeTodoReminderNotification(for: self)
    }
    
    /// Remove from events.
    
    func removeFromEvents() {
        guard UserDefaultManager.bool(forKey: .SettingCalendarsSync), let identifier = eventIdentifier else { return }
        
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
        guard UserDefaultManager.bool(forKey: .SettingRemindersSync), let identifier = reminderIdentifier else { return }
        
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

//
//  +ToDo.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/16/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import EventKit
import CoreData

extension ToDo {
    
    /// The max length limit for goal string.
    ///
    /// - Returns: The max characters limit in integer
    
    open class func goalMaxLimit() -> Int {
        return 150
    }
    
    /// Find all to-dos.
    
    class func findAll(in managedObjectContext: NSManagedObjectContext) -> [ToDo] {
        // Create Fetch Request
        let request: NSFetchRequest<ToDo> = fetchRequest()
        
        return (try? managedObjectContext.fetch(request)) ?? []
    }
    
    /// Set default due date.
    
    func setDefaultDueDate() {
        let calendar = Calendar.current
        
        // Get components from calendar
        var components = calendar.dateComponents([.day, .month, .year, .hour, .minute], from: Date())
        // Set to midnight
        components.hour = 23
        components.minute = 59
        
        let midnight = calendar.date(from: components)
        
        due = midnight
    }
    
    // MARK: - Configurations after creation.
    
    func created() {
        // Assign UUID
        uuid = UUID().uuidString
        // Set repeat info to none.
        if repeatInfo == nil {
            setRepeatInfo(info: ToDo.Repeat(type: .None, frequency: 1, unit: .Day, endDate: nil))
        }
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
            event.notes = notes
            
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
            reminder.notes = notes
            
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
            // Handle notifications
            DispatchQueue.main.async {
                self.completed = completed
                self.completedAt = completed ? Date() : nil
                
                if completed {
                    // Renew itself if it is repeated
                    self.renewIfRepeated()
                    // Remove notifications
                    NotificationManager.removeTodoReminderNotification(for: self)
                    // Remove from events
                    self.removeFromEvents()
                } else {
                    // Restore notifications
                    NotificationManager.registerTodoReminderNotification(for: self)
                    // Restore to events
                    self.createToEvents()
                }
                // Set completed to reminders
                self.setCompletedToReminders(completed: completed)
            }
        }
    }
    
    /// Renew to-do if it is repeated.
    
    internal func renewIfRepeated() {
        if let info = getRepeatInfo() {
            // Get next recurring date
            var component: Calendar.Component = .day
            var amount: Int = info.frequency
            
            switch info.type {
            case .None:
                return
            case .Daily:
                component = .day
                amount = 1
            case .Weekday:
                component = .weekday
                amount = 1
            case .Weekly:
                component = .day
                amount = 7
            case .Monthly:
                component = .month
                amount = 1
            case .Annually:
                component = .year
                amount = 1
            case .Regularly, .AfterCompletion:
                switch info.unit {
                case .Minute:
                    component = .minute
                case .Hour:
                    component = .hour
                case .Month:
                    component = .month
                case .Weekday:
                    component = .weekday
                case .Week:
                    amount = amount * 7
                case .Year:
                    component = .year
                default:
                    break
                }
            }
            
            let baseDate: Date = info.type == .AfterCompletion ? Date() : (due ?? Date())
            var nextDate = Calendar.current.date(byAdding: component, value: amount, to: baseDate)!
            
            if component == .weekday {
                let dateFormatter = DateFormatter.inEnglish()
                dateFormatter.dateFormat = "EEE"
                
                switch dateFormatter.string(from: nextDate) {
                case "Sat":
                    // Set date to next monday by adding two more days
                    nextDate = Calendar.current.date(byAdding: .day, value: 2, to: nextDate)!
                case "Sun":
                    // Set date to next monday by adding one more day
                    nextDate = Calendar.current.date(byAdding: .day, value: 2, to: nextDate)!
                default:
                    break
                }
            }
            
            // Renew for remind notification
            if let remindAt = remindAt {
                self.remindAt = Calendar.current.date(byAdding: component, value: amount, to: info.type == .AfterCompletion ? Date() : remindAt)
            }
            
            // Check if passed end repeating date
            if let endDate = info.endDate, nextDate > endDate {
                return
            }
            
            // Renew self
            due = nextDate
            
            if self.completed {
                self.complete(completed: false)
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
        guard UserDefaultManager.bool(forKey: .RemindersSync), let identifier = reminderIdentifier else { return }
        
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

extension ToDo {
    
    /// Repeat types.
    
    public enum RepeatType: String, Codable {
        case None = "none"
        case Daily = "daily"
        case Weekly = "weekly"
        case Weekday = "weekday"
        case Monthly = "monthly"
        case Annually = "yearly"
        case Regularly = "regularly"
        case AfterCompletion = "after-completion"
    }
    
    /// Repeat regularly unit.
    
    public enum RepeatUnit: String, Codable {
        case Minute = "minute"
        case Hour = "hour"
        case Day = "day"
        case Weekday = "weekday"
        case Week = "week"
        case Month = "month"
        case Year = "year"
    }
    
    /// Repeat structure.
    
    struct Repeat: Codable {
        var type: RepeatType = .None
        var frequency: Int = 1
        var unit: RepeatUnit = .Day
        var endDate: Date?
    }
    
    /// Repeat types.
    
    static let repeatTypes: [RepeatType] = [
        .None, .Daily, .Weekday, .Weekly, .Monthly, .Annually, .Regularly, .AfterCompletion
    ]
    
    /// Repeat units.
    
    static let repeatUnits: [RepeatUnit] = [
        .Minute, .Hour, .Day, .Weekday, .Week, .Month, .Year
    ]
    
    /// Retrieve repeat info.
    
    func getRepeatInfo() -> ToDo.Repeat? {
        if let data = repeatInfo {
            return try? JSONDecoder().decode(ToDo.Repeat.self, from: data)
        }
        
        return nil
    }
    
    /// Set repeat info to data.
    
    func setRepeatInfo(info: ToDo.Repeat?) {
        if let info = info {
            if let data = try? JSONEncoder().encode(info) {
                repeatInfo = data
            }
        }
    }
}

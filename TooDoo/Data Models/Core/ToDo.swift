//
//  ToDo.swift
//  TooDoo
//
//  Created by Cali Castle  on 5/22/18.
//  Copyright © 2018 Cali Castle . All rights reserved.
//

import EventKit
import Foundation
import RealmSwift

public final class ToDo: Object {
    
    @objc dynamic private(set) var id: String = AUUID().idString
    
    /// Dates
    @objc dynamic private(set) var createdAt: Date = Date()
    @objc dynamic private(set) var updatedAt: Date = Date()
    @objc dynamic var dueAt: Date?
    @objc dynamic var remindAt: Date?
    @objc dynamic var completedAt: Date?
    @objc dynamic var movedToTrashAt: Date?
    
    @objc dynamic var goal: String = ""
    @objc dynamic var notes: String?
    
    @objc dynamic var repeatInfo: Data?
    
    @objc dynamic private(set) var systemEventIdentifier: String?
    @objc dynamic private(set) var systemReminderIdentifier: String?
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    @objc dynamic var list: ToDoList?
    
    /// Make a fresh instance with additional steps
    ///
    /// - Returns: new instance
    public static func make() -> ToDo {
        let todo = self.init()
        
        return todo
    }
    
    public var completed: Bool {
        return completedAt != nil
    }
    
}

extension ToDo: Timestampable {}
extension ToDo: EventSyncable, ReminderSyncable {}

extension ToDo {
    
    /// The max length limit for goal string.
    ///
    /// - Returns: The max characters limit in integer
    open class func goalMaxLimit() -> Int {
        return 150
    }
    
    /// Find all to-dos.
    static func findAll() -> [ToDo] {
        return []
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
        
        dueAt = midnight
    }
    
    // MARK: - Configurations after creation.
    
    func created() {
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
            event.title = goal
            event.notes = notes
            
            if let due = dueAt {
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
                systemEventIdentifier = event.eventIdentifier
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
            reminder.title = goal
            reminder.isCompleted = false
            reminder.notes = notes
            
            if let due = dueAt {
                reminder.dueDateComponents = Calendar.current.dateComponents(in: .current, from: due)
            }
            
            do {
                try eventStore.save(reminder, commit: true)
                // Save reminder identifier
                systemReminderIdentifier = reminder.calendarItemIdentifier
            } catch {
                print("Error trying to save EKReminder")
                print("\(error.localizedDescription)")
            }
        }
    }
    
    /// Set completed attribute.
    func complete(completed: Bool) {
        // Must set to different complete state
        guard completed ^^ (completedAt == nil) else { return }
        
        // Handle notifications
        DispatchQueue.main.async {
            self.completedAt = completed ? Date() : nil
            
            if completed {
                // Renew itself if it is repeated
                self.renewDates()
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
    
    /// Renew all the dates.
    internal func renewDates() {
        renewDue()
        renewRemindAt()
    }
    
    /// Renew a date if it is to be repeated.
    internal func renewIfRepeated(_ dateToBeRenewed: inout Date?) {
        guard let info = getRepeatInfo(), let date = dateToBeRenewed else { return }
        
        // Get next recurring date
        guard let nextDate = info.getNextDate(date) else { return }
        
        // Add renewal calculation
        dateToBeRenewed = nextDate
        
        // Check if passed end repeating date
        if let endDate = info.endDate, nextDate > endDate { return }
        
        // Set incomplete once it's renewed
        if let _ = completedAt {
            self.complete(completed: false)
        }
    }
    
    
    /// Renew due date if needed.
    internal func renewDue() {
        renewIfRepeated(&dueAt)
    }
    
    /// Renew remind at date if needed.
    internal func renewRemindAt() {
        renewIfRepeated(&remindAt)
    }
    
    /// Calculate next weekday accordingly (excluding Sat, Sun.)
    ///
    /// - Parameter date: The referenced date
    open class func calculateNextDateForWeekday(_ date: inout Date, amount: Int) {
        var daysToAdd = amount
        
        repeat {
            date = date.next(.day)
            
            if date.isWeekend {
                // If next day is weekend
                continue
            }
            
            daysToAdd -= 1
        } while daysToAdd != 0
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
        guard UserDefaultManager.bool(forKey: .RemindersSync), let identifier = systemReminderIdentifier else { return }
        
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
        guard UserDefaultManager.bool(forKey: .CalendarsSync), let identifier = systemEventIdentifier else { return }
        
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
        guard UserDefaultManager.bool(forKey: .RemindersSync), let identifier = systemReminderIdentifier else { return }
        
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
    
}

extension ToDo {
    
    /// Repeat types.
    public enum RepeatType: String, Codable {
        case None
        case Daily
        case Weekly
        case Weekday
        case Monthly
        case Annually
        case Regularly
        case AfterCompletion
    }
    
    /// Repeat regularly unit.
    public enum RepeatUnit: String, Codable {
        case Minute
        case Hour
        case Day
        case Weekday
        case Week
        case Month
        case Year
    }
    
    /// Repeat structure.
    struct Repeat: Codable {
        var type: RepeatType = .None
        var frequency: Int = 1
        var unit: RepeatUnit = .Day
        var endDate: Date?
        
        func getNextDate(_ date: Date) -> Date? {
            let info = self
            
            var component: Calendar.Component = .day
            var amount: Int = info.frequency
            
            switch info.type {
            case .None:
                return nil
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
            
            // Get initial next date
            var nextDate: Date = info.type == .AfterCompletion ? Date() : date
            
            if component == .weekday {
                // Calculate next weekday
                calculateNextDateForWeekday(&nextDate, amount: amount)
            } else {
                // Calculate next by component
                nextDate = Calendar.current.date(byAdding: component, value: amount, to: nextDate)!
            }
            
            // Add renewal calculation
            return nextDate
        }
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

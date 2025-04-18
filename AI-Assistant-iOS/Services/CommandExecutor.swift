import Foundation
import UIKit
import EventKit
import UserNotifications

// Protocol for dependency injection and testability.
protocol CommandExecuting {
    func execute(command: String, completion: @escaping (String) -> Void)
}

class CommandExecutor: CommandExecuting, ObservableObject {
    
    // MARK: - Helper Methods for Command Classification
    
    private func isAlarmCommand(_ input: String) -> Bool {
        return input.contains("alarm") || input.contains("wake me up")
    }
    
    private func isEmailCommand(_ input: String) -> Bool {
        return input.contains("email")
    }
    
    private func isReminderCommand(_ input: String) -> Bool {
        return input.contains("reminder") || input.contains("remind me")
    }
    
    private func isTaskScheduleCommand(_ input: String) -> Bool {
        return input.contains("schedule") || input.contains("task") || input.contains("meeting")
    }
    
    private func isMusicCommand(_ input: String) -> Bool {
        return input.contains("music")
    }
    
    private func isWeatherCommand(_ input: String) -> Bool {
        return input.contains("weather") || input.contains("forecast") || input.contains("temperature")
    }
    
    private func isTipCommand(_ input: String) -> Bool {
        return input.contains("calculate") && input.contains("tip")
    }
    
    private func isTimeCommand(_ input: String) -> Bool {
        return input.contains("time")
    }
    
    private func isDateCommand(_ input: String) -> Bool {
        return input.contains("date")
    }
    
    // MARK: - Main Command Execution
    
    func execute(command: String, completion: @escaping (String) -> Void) {
        let lowercased = command.lowercased()
        
        if isAlarmCommand(lowercased) {
            if let forRange = lowercased.range(of: "for ") {
                let timeCandidate = String(command[forRange.upperBound...])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                let alarmManager = AlarmManager()
                alarmManager.setAlarm(for: timeCandidate) { success, message in
                    DispatchQueue.main.async {
                        completion(message)
                    }
                }
            } else {
                completion("Please specify a time for the alarm (e.g., 'set alarm for 10pm').")
            }
        
        } else if isEmailCommand(lowercased) {
            guard let toRange = lowercased.range(of: "to ") else {
                completion("Email command is missing the recipient.")
                return
            }
            let afterTo = command[toRange.upperBound...]
            guard let subjectRange = afterTo.range(of: " subject:") else {
                completion("Email command is missing the 'subject:' keyword.")
                return
            }
            let recipient = String(afterTo[..<subjectRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
            let afterSubject = afterTo[subjectRange.upperBound...]
            guard let bodyRange = afterSubject.range(of: " body:") else {
                completion("Email command is missing the 'body:' keyword.")
                return
            }
            let subjectText = String(afterSubject[..<bodyRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
            let bodyText = String(afterSubject[bodyRange.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
            
            var urlString = "mailto:\(recipient)"
            var queryItems = [String]()
            if !subjectText.isEmpty {
                queryItems.append("subject=\(subjectText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")
            }
            if !bodyText.isEmpty {
                queryItems.append("body=\(bodyText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")
            }
            if !queryItems.isEmpty {
                urlString += "?\(queryItems.joined(separator: "&"))"
            }
            
            if let url = URL(string: urlString) {
                DispatchQueue.main.async {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                completion("Opening email draft for \(recipient).")
            } else {
                completion("Failed to construct the email URL. Please check your command format.")
            }
        
        } else if isReminderCommand(lowercased) {
            let reminderText: String
            if let range = lowercased.range(of: "reminder:") {
                reminderText = String(command[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                reminderText = command.replacingOccurrences(of: "remind me", with: "", options: .caseInsensitive)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            let eventStore = EKEventStore()
            eventStore.requestAccess(to: .reminder) { granted, error in
                if !granted {
                    DispatchQueue.main.async {
                        completion("Reminder access was not granted.")
                    }
                    return
                }
                let reminder = EKReminder(eventStore: eventStore)
                reminder.title = reminderText.isEmpty ? "New Reminder" : reminderText
                reminder.calendar = eventStore.defaultCalendarForNewReminders()
                do {
                    try eventStore.save(reminder, commit: true)
                    DispatchQueue.main.async {
                        completion("Reminder set: \(reminder.title)")
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion("Error setting reminder: \(error.localizedDescription)")
                    }
                }
            }
        
        } else if isTaskScheduleCommand(lowercased) {
            let taskText: String
            if let range = lowercased.range(of: "schedule task:") {
                taskText = String(command[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                taskText = "New Task"
            }
            
            let eventStore = EKEventStore()
            eventStore.requestAccess(to: .event) { granted, error in
                if !granted {
                    DispatchQueue.main.async {
                        completion("Calendar access was not granted.")
                    }
                    return
                }
                let event = EKEvent(eventStore: eventStore)
                event.title = taskText
                event.startDate = Date().addingTimeInterval(3600)
                event.endDate = event.startDate.addingTimeInterval(3600)
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent, commit: true)
                    DispatchQueue.main.async {
                        completion("Task scheduled: \(event.title)")
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion("Error scheduling task: \(error.localizedDescription)")
                    }
                }
            }
        
        } else if isMusicCommand(lowercased) {
            let moodMapping: [String: String] = [
                "happy": "https://open.spotify.com/playlist/37i9dQZF1DXdPec7aLTmlC",
                "sad": "https://open.spotify.com/playlist/37i9dQZF1DWVrtsSlLKzro",
                "energetic": "https://open.spotify.com/playlist/37i9dQZF1DX0BcQWzuB7ZO",
                "calm": "https://open.spotify.com/playlist/37i9dQZF1DX4sWSpwq3LiO"
            ]
            let moodKey = moodMapping.keys.first { lowercased.contains($0) } ?? "happy"
            if let playlistURLString = moodMapping[moodKey], let url = URL(string: playlistURLString) {
                DispatchQueue.main.async {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                completion("Playing \(moodKey) music.")
            } else {
                completion("Couldn't find a playlist for the specified mood.")
            }
        
        } else if isWeatherCommand(lowercased) {
            completion("Current weather: Sunny, 75°F with a light breeze.")
        
        } else if isTipCommand(lowercased) {
            if let forRange = lowercased.range(of: "for ") {
                let afterFor = command[forRange.upperBound...]
                if let atRange = afterFor.range(of: " at ") {
                    let billStr = String(afterFor[..<atRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
                    let afterAt = afterFor[atRange.upperBound...]
                    let percentStr = String(afterAt).replacingOccurrences(of: "%", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                    if let bill = Double(billStr), let percentage = Double(percentStr) {
                        let tip = bill * percentage / 100.0
                        let total = bill + tip
                        completion("For a bill of \(bill) with a tip of \(percentage)%, the tip is \(tip) and the total is \(total).")
                    } else {
                        completion("Could not parse the bill amount or tip percentage.")
                    }
                } else {
                    completion("Please specify the tip percentage using 'at'.")
                }
            } else {
                completion("Command format not recognized for calculating tip.")
            }
        } else if isTimeCommand(lowercased) {
            let formatter = DateFormatter()
            formatter.timeStyle = .medium
            let currentTime = formatter.string(from: Date())
            completion("The current time is \(currentTime).")
        
        } else if isDateCommand(lowercased) {
            let formatter = DateFormatter()
            formatter.dateStyle = .full
            let currentDate = formatter.string(from: Date())
            completion("Today's date is \(currentDate).")
        
        } else {
            completion("I did not understand the command: \(command)")
        }
    }
    
    // MARK: - Helper: Summarize Text
    private func summarize(text: String) -> String {
        let sentences = text.components(separatedBy: ". ")
        if let firstSentence = sentences.first, !firstSentence.isEmpty {
            return firstSentence.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return text
    }
}

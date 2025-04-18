import Foundation
import UserNotifications

class AlarmManager {
    
    /// Tries multiple time formats to parse a given time string.
    /// Supported formats include 24‑hour ("HH:mm") and 12‑hour ("hha", "ha", "h:mma", "hh:mma").
    /// - Parameter timeString: The input time string.
    /// - Returns: A Date representing the parsed time, or nil if parsing fails.
    private func parseTime(from timeString: String) -> Date? {
        let formats = ["HH:mm", "hha", "ha", "h:mma", "hh:mma"]
        for format in formats {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.locale = Locale(identifier: "en_US_POSIX")
            if let date = formatter.date(from: timeString) {
                return date
            }
        }
        return nil
    }
    
    /// Sets an alarm based on a provided time string.
    /// - Parameters:
    ///   - timeString: A flexible time string (e.g., "10pm", "10:30 PM", "07:00").
    ///   - completion: A closure returning a success flag and a message.
    func setAlarm(for timeString: String, completion: @escaping (Bool, String) -> Void) {
        guard let alarmTime = parseTime(from: timeString) else {
            completion(false, "Time format invalid. Please specify a valid time (e.g., '10pm', '07:00').")
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        let alarmComponents = calendar.dateComponents([.hour, .minute], from: alarmTime)
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: now)
        dateComponents.hour = alarmComponents.hour
        dateComponents.minute = alarmComponents.minute
        
        guard let scheduledDate = calendar.date(from: dateComponents) else {
            completion(false, "Could not construct the scheduled date.")
            return
        }
        
        scheduleAlarm(at: scheduledDate, completion: completion)
    }
    
    /// Schedules a local notification as an alarm at the specified date.
    /// - Parameters:
    ///   - date: The date and time for the alarm.
    ///   - completion: A closure returning a success flag and a message.
    private func scheduleAlarm(at date: Date, completion: @escaping (Bool, String) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if !granted {
                DispatchQueue.main.async {
                    completion(false, "Notification permission was not granted.")
                }
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Alarm"
            content.body = "Your alarm is ringing!"
            content.sound = UNNotificationSound.default
            
            let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            center.add(request) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(false, "Failed to set alarm: \(error.localizedDescription)")
                    } else {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "hh:mm a"
                        let formattedTime = formatter.string(from: date)
                        completion(true, "Alarm set for \(formattedTime).")
                    }
                }
            }
        }
    }
}

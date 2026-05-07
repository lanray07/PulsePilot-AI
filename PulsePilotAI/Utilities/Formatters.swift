import Foundation

enum Formatters {
    static func hours(_ value: Double) -> String {
        if value < 0.1 { return "0h" }
        let whole = Int(value)
        let minutes = Int(((value - Double(whole)) * 60).rounded())
        if whole == 0 {
            return "\(minutes)m"
        }
        if minutes == 0 {
            return "\(whole)h"
        }
        return "\(whole)h \(minutes)m"
    }

    static func liters(_ value: Double) -> String {
        String(format: "%.1fL", value)
    }

    static func number(_ value: Int) -> String {
        value.formatted()
    }

    static func dateKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    static func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

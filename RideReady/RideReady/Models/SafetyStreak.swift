import Foundation

/// Consecutive calendar days with a completed pre-ride inspection.
///
/// Business Rule: increments on the next calendar day; same-day repeats do not
/// count; a missed day resets to 1.
struct SafetyStreak: Codable {
    var consecutiveDays: Int
    var lastCompletedOn: Date?
}

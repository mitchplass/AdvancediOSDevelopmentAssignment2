import Foundation

/// Loads and saves the motorcycle, walk-arounds, and safety streak.
///
/// Business Rule: an inspection cannot start without a motorcycle profile.
protocol RideReadyStoring {
    func motorcycle() -> Motorcycle?
    func save(_ motorcycle: Motorcycle)
    func activeInspection() -> PreRideInspection?
    func save(_ inspection: PreRideInspection)
    func latestCompletedInspection() -> PreRideInspection?
    func streak() -> SafetyStreak
    func save(_ streak: SafetyStreak)
}

/// In-memory store for the current motorcycle, inspections, and streak.
final class InMemoryRideReadyStore: RideReadyStoring {
    private var currentMotorcycle: Motorcycle?
    private var inspections: [PreRideInspection] = []
    private var currentStreak = SafetyStreak(consecutiveDays: 0, lastCompletedOn: nil)

    func motorcycle() -> Motorcycle? {
        currentMotorcycle
    }

    func save(_ motorcycle: Motorcycle) {
        currentMotorcycle = motorcycle
    }

    func activeInspection() -> PreRideInspection? {
        inspections.first { $0.completedAt == nil }
    }

    func save(_ inspection: PreRideInspection) {
        if let index = inspections.firstIndex(where: { $0.id == inspection.id }) {
            inspections[index] = inspection
        } else {
            inspections.append(inspection)
        }
    }

    func latestCompletedInspection() -> PreRideInspection? {
        inspections
            .filter { $0.completedAt != nil }
            .sorted { lhs, rhs in
                (lhs.completedAt ?? .distantPast) > (rhs.completedAt ?? .distantPast)
            }
            .first
    }

    func streak() -> SafetyStreak {
        currentStreak
    }

    func save(_ streak: SafetyStreak) {
        currentStreak = streak
    }
}

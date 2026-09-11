import Foundation

/// Logs a finished pre-ride walk-around and updates the safety streak.
///
/// Business Rule: every required item must be recorded. Ride-ready is only
/// allowed when none need attention. The streak counts consecutive calendar days.
struct CompletePreRideInspectionUseCase {
    let store: RideReadyStoring
    let now: () -> Date
    let calendar: Calendar

    init(
        store: RideReadyStoring,
        now: @escaping () -> Date = Date.init,
        calendar: Calendar = .current
    ) {
        self.store = store
        self.now = now
        self.calendar = calendar
    }

    func complete(as readiness: RideReadiness) throws -> PreRideInspection {
        guard var inspection = store.activeInspection() else {
            throw CompletePreRideInspectionError.walkAroundNotStarted
        }

        let required = inspection.motorcycle.requiredInspectionItems()
        let recorded = Set(inspection.findings.map(\.item))
        let missing = required.filter { !recorded.contains($0) }
        if !missing.isEmpty {
            throw CompletePreRideInspectionError.uncheckedItems(missing)
        }

        if readiness == .readyToRide,
           inspection.findings.contains(where: { $0.result == .needsAttention }) {
            throw CompletePreRideInspectionError.itemNeedsAttention
        }

        let completedAt = now()
        inspection.completedAt = completedAt
        inspection.readiness = readiness
        store.save(inspection)
        store.save(updatedStreak(on: completedAt))
        return inspection
    }

    private func updatedStreak(on date: Date) -> SafetyStreak {
        let streak = store.streak()
        guard let lastCompletedOn = streak.lastCompletedOn else {
            return SafetyStreak(consecutiveDays: 1, lastCompletedOn: date)
        }

        if calendar.isDate(date, inSameDayAs: lastCompletedOn) {
            return streak
        }

        if let previousDay = calendar.date(byAdding: .day, value: -1, to: date),
           calendar.isDate(lastCompletedOn, inSameDayAs: previousDay) {
            return SafetyStreak(
                consecutiveDays: streak.consecutiveDays + 1,
                lastCompletedOn: date
            )
        }

        return SafetyStreak(consecutiveDays: 1, lastCompletedOn: date)
    }
}

/// Failures when Alex tries to log a ride after the walk-around.
enum CompletePreRideInspectionError: LocalizedError, Equatable {
    case walkAroundNotStarted
    case uncheckedItems([InspectionItem])
    case itemNeedsAttention

    var errorDescription: String? {
        switch self {
        case .walkAroundNotStarted:
            return "You haven't started a pre-ride check yet. Start a walk-around first."
        case .uncheckedItems(let items):
            let names = items.map(\.title).joined(separator: ", ")
            return "Some checks are still open (\(names)). Finish them before you log this ride."
        case .itemNeedsAttention:
            return "Something on this walk-around needs attention. Do not treat the bike as ride ready. Fix it, or log this check as not ride ready."
        }
    }
}

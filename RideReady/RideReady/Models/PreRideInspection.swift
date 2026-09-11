import Foundation

/// The rider's judgement of one inspection item.
enum InspectionResult {
    case ok
    case needsAttention
}

/// One item result recorded during a pre-ride walk-around.
///
/// Business Rule: `needsAttention` means the inspection cannot complete as ride-ready.
struct InspectionFinding {
    let item: InspectionItem
    let result: InspectionResult
}

/// Whether the rider may leave after this walk-around.
///
/// Business Rule: `readyToRide` requires every item to be `ok`.
enum RideReadiness {
    case readyToRide
    case notRideReady
}

/// A walk-around of the motorcycle before the rider leaves.
///
/// Business Rule: cannot be `readyToRide` while items are unchecked or need attention.
struct PreRideInspection {
    let id: UUID
    let motorcycle: Motorcycle
    let startedAt: Date
    var findings: [InspectionFinding]
    var completedAt: Date?
    var readiness: RideReadiness?
}

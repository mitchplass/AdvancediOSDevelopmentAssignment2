import Foundation

/// Starts a pre-ride walk-around for the rider's motorcycle.
///
/// Business Rule: a motorcycle profile must exist, and no walk-around can already
/// be in progress.
struct StartPreRideInspectionUseCase {
    let store: RideReadyStoring

    func start() throws -> PreRideInspection {
        guard let motorcycle = store.motorcycle() else {
            throw StartPreRideInspectionError.motorcycleNotSetUp
        }

        if store.activeInspection() != nil {
            throw StartPreRideInspectionError.inspectionAlreadyInProgress
        }

        let inspection = PreRideInspection(
            id: UUID(),
            motorcycle: motorcycle,
            startedAt: Date(),
            findings: []
        )
        store.save(inspection)
        return inspection
    }
}

/// Failures when Alex tries to start a pre-ride check.
enum StartPreRideInspectionError: LocalizedError, Equatable {
    case motorcycleNotSetUp
    case inspectionAlreadyInProgress

    var errorDescription: String? {
        switch self {
        case .motorcycleNotSetUp:
            return "No bike is set up yet. Add your motorcycle before you start a pre-ride check."
        case .inspectionAlreadyInProgress:
            return "You already have a pre-ride check in progress. Finish that walk-around before starting another."
        }
    }
}

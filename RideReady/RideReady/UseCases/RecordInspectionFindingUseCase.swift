import Foundation

/// Records OK or needs-attention for one item on the current walk-around.
///
/// Business Rule: a walk-around must already be in progress, and the item must
/// belong on this motorcycle (no chain check on a shaft-drive bike).
struct RecordInspectionFindingUseCase {
    let store: RideReadyStoring

    func record(_ result: InspectionResult, for item: InspectionItem) throws -> PreRideInspection {
        guard var inspection = store.activeInspection() else {
            throw RecordInspectionFindingError.walkAroundNotStarted
        }

        guard item.isRequired(on: inspection.motorcycle) else {
            throw RecordInspectionFindingError.itemNotOnThisBike(item)
        }

        let finding = InspectionFinding(item: item, result: result)
        if let index = inspection.findings.firstIndex(where: { $0.item == item }) {
            inspection.findings[index] = finding
        } else {
            inspection.findings.append(finding)
        }

        store.save(inspection)
        return inspection
    }
}

/// Failures when Alex tries to mark a check OK or as an issue.
enum RecordInspectionFindingError: LocalizedError, Equatable {
    case walkAroundNotStarted
    case itemNotOnThisBike(InspectionItem)

    var errorDescription: String? {
        switch self {
        case .walkAroundNotStarted:
            return "You haven't started a pre-ride check yet. Start a walk-around first."
        case .itemNotOnThisBike(.chain):
            return "This bike has no chain to inspect. Continue with the checks that match your motorcycle."
        case .itemNotOnThisBike(let item):
            return "\(item.title) is not on this bike's pre-ride check. Continue with the items that match your motorcycle."
        }
    }
}

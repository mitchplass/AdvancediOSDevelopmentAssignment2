import Combine
import Foundation

/// Checklist screen state for the current walk-around.
final class ChecklistViewModel: ObservableObject {
    struct Row: Identifiable {
        let item: InspectionItem
        var id: InspectionItem { item }
        let title: String
        let isComplete: Bool
        let needsAttention: Bool
    }

    @Published private(set) var rows: [Row] = []
    @Published private(set) var progressText = ""
    @Published private(set) var canReviewRideReady = false

    private let store: RideReadyStoring

    init(store: RideReadyStoring) {
        self.store = store
        reload()
    }

    func reload() {
        guard let inspection = store.activeInspection() else {
            rows = []
            progressText = "0 of 0 complete"
            canReviewRideReady = false
            return
        }

        let items = inspection.motorcycle.requiredInspectionItems()
        rows = items.map { item in
            let finding = inspection.findings.first { $0.item == item }
            return Row(
                item: item,
                title: item.title,
                isComplete: finding != nil,
                needsAttention: finding?.result == .needsAttention
            )
        }
        let done = rows.filter(\.isComplete).count
        progressText = "\(done) of \(rows.count) complete"
        canReviewRideReady = done == rows.count && !rows.isEmpty
    }
}

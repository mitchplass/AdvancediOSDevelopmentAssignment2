import Combine
import Foundation

/// Item detail state: guidance and OK / Issue for one check.
final class ItemDetailViewModel: ObservableObject {
    let title: String
    let guidance: String
    @Published private(set) var selectedResult: InspectionResult?
    @Published var riderError: String?

    private let item: InspectionItem
    private let recordFinding: RecordInspectionFindingUseCase

    init(item: InspectionItem, store: RideReadyStoring) {
        self.item = item
        recordFinding = RecordInspectionFindingUseCase(store: store)
        let motorcycle = store.activeInspection()?.motorcycle ?? .yamahaMT07()
        title = item.title
        guidance = item.guidance(for: motorcycle)
        selectedResult = store.activeInspection()?.findings.first { $0.item == item }?.result
    }

    func markOK() {
        record(.ok)
    }

    func markIssue() {
        record(.needsAttention)
    }

    private func record(_ result: InspectionResult) {
        do {
            _ = try recordFinding.record(result, for: item)
            selectedResult = result
            riderError = nil
        } catch {
            riderError = error.localizedDescription
        }
    }
}

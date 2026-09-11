import Combine
import Foundation

/// Ride-ready screen state after every item has been recorded.
final class RideReadyViewModel: ObservableObject {
    @Published private(set) var headline: String
    @Published private(set) var detail: String
    @Published private(set) var isRideReady: Bool
    @Published private(set) var logButtonTitle: String
    @Published var riderError: String?
    @Published var didLog = false

    private let completeInspection: CompletePreRideInspectionUseCase

    init(store: RideReadyStoring) {
        completeInspection = CompletePreRideInspectionUseCase(store: store)
        let hasIssue = store.activeInspection()?.findings.contains { $0.result == .needsAttention } ?? false
        isRideReady = !hasIssue
        if hasIssue {
            headline = "Not ride ready yet"
            detail = "Something needs attention. Do not treat this bike as ride ready."
            logButtonTitle = "Log as not ride ready"
        } else {
            headline = "You're ride ready"
            detail = "All checks passed. You're ride ready."
            logButtonTitle = "Log ride"
        }
    }

    func logRide() {
        do {
            _ = try completeInspection.complete(as: isRideReady ? .readyToRide : .notRideReady)
            didLog = true
            riderError = nil
        } catch {
            riderError = error.localizedDescription
        }
    }
}

import Combine
import Foundation

/// Home screen state: bike, streak, and starting or continuing a walk-around.
final class HomeViewModel: ObservableObject {
    @Published private(set) var motorcycleName = ""
    @Published private(set) var streakText = "0 day streak"
    @Published private(set) var lastCheckText = "No checks logged yet"
    @Published private(set) var startButtonTitle = "Start pre-ride check"
    @Published private(set) var bikeProfileButtonTitle = "Edit bike profile"
    @Published var riderError: String?

    private let store: RideReadyStoring
    private let startInspection: StartPreRideInspectionUseCase

    init(store: RideReadyStoring) {
        self.store = store
        startInspection = StartPreRideInspectionUseCase(store: store)
        reload()
    }

    func reload() {
        motorcycleName = store.motorcycle()?.name ?? "No bike set up"
        let days = store.streak().consecutiveDays
        streakText = days == 1 ? "1 day streak" : "\(days) day streak"
        if let last = store.latestCompletedInspection()?.completedAt {
            if Calendar.current.isDateInToday(last) {
                lastCheckText = "Last check: today, \(Self.lastCheckTimeFormatter.string(from: last))"
            } else {
                lastCheckText = "Last check: \(Self.lastCheckFormatter.string(from: last))"
            }
        } else {
            lastCheckText = "No checks logged yet"
        }
        startButtonTitle = store.activeInspection() == nil
            ? "Start pre-ride check"
            : "Continue pre-ride check"
        bikeProfileButtonTitle = store.motorcycle() == nil
            ? "Set up your motorcycle"
            : "Edit bike profile"
    }

    func startOrContinueCheck() -> Bool {
        riderError = nil
        if store.activeInspection() != nil {
            return true
        }
        do {
            _ = try startInspection.start()
            reload()
            return true
        } catch {
            riderError = error.localizedDescription
            return false
        }
    }

    private static let lastCheckFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    private static let lastCheckTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
}

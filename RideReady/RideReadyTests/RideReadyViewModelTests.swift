import XCTest
@testable import RideReady

final class RideReadyViewModelTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!
    private var store: UserDefaultsRideReadyStore!

    override func setUpWithError() throws {
        suiteName = "RideReadyTests.\(UUID().uuidString)"
        defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        store = UserDefaultsRideReadyStore(defaults: defaults)
        store.save(.yamahaMT07())
        _ = try StartPreRideInspectionUseCase(store: store).start()
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        store = nil
        suiteName = nil
    }

    func test_logRide_completesWalkAround_whenEveryCheckPassed() throws {
        try recordAll(.ok)
        let viewModel = RideReadyViewModel(store: store)

        XCTAssertTrue(viewModel.isRideReady)
        XCTAssertEqual(viewModel.headline, "You're ride ready")
        XCTAssertEqual(viewModel.logButtonTitle, "Log ride")

        viewModel.logRide()

        XCTAssertTrue(viewModel.didLog)
        XCTAssertNil(store.activeInspection())
        XCTAssertEqual(store.latestCompletedInspection()?.readiness, .readyToRide)
    }

    func test_logRide_recordsNotRideReady_whenAnItemNeedsAttention() throws {
        try recordAll(.ok)
        try RecordInspectionFindingUseCase(store: store).record(.needsAttention, for: .tyres)
        let viewModel = RideReadyViewModel(store: store)

        XCTAssertFalse(viewModel.isRideReady)
        XCTAssertEqual(viewModel.logButtonTitle, "Log as not ride ready")

        viewModel.logRide()

        XCTAssertTrue(viewModel.didLog)
        XCTAssertEqual(store.latestCompletedInspection()?.readiness, .notRideReady)
    }

    private func recordAll(_ result: InspectionResult) throws {
        let record = RecordInspectionFindingUseCase(store: store)
        for item in Motorcycle.yamahaMT07().requiredInspectionItems() {
            try record.record(result, for: item)
        }
    }
}

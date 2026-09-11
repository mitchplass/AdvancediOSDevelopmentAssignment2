import XCTest
@testable import RideReady

final class ChecklistViewModelTests: XCTestCase {
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

    func test_reload_listsRequiredItems_andBlocksReviewUntilEveryCheckIsRecorded() throws {
        let viewModel = ChecklistViewModel(store: store)

        XCTAssertEqual(viewModel.rows.map(\.title), ["Tyres", "Chain", "Lights", "Fluids and gear"])
        XCTAssertFalse(viewModel.canReviewRideReady)
        XCTAssertEqual(viewModel.progressText, "0 of 4 complete")

        let record = RecordInspectionFindingUseCase(store: store)
        try record.record(.ok, for: .tyres)
        try record.record(.ok, for: .chain)
        try record.record(.ok, for: .lights)
        viewModel.reload()

        XCTAssertFalse(viewModel.canReviewRideReady)
        XCTAssertEqual(viewModel.progressText, "3 of 4 complete")

        try record.record(.needsAttention, for: .fluidsAndGear)
        viewModel.reload()

        XCTAssertTrue(viewModel.canReviewRideReady)
        XCTAssertTrue(viewModel.rows.last?.needsAttention ?? false)
    }
}

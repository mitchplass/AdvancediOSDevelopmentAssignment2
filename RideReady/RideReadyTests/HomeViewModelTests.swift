import XCTest
@testable import RideReady

final class HomeViewModelTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!
    private var store: UserDefaultsRideReadyStore!

    override func setUpWithError() throws {
        suiteName = "RideReadyTests.\(UUID().uuidString)"
        defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        store = UserDefaultsRideReadyStore(defaults: defaults)
        store.save(.yamahaMT07())
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        store = nil
        suiteName = nil
    }

    func test_startOrContinueCheck_startsWalkAround_whenMotorcycleIsSetUp() {
        let viewModel = HomeViewModel(store: store)

        XCTAssertTrue(viewModel.startOrContinueCheck())
        XCTAssertEqual(viewModel.motorcycleName, "Yamaha MT-07")
        XCTAssertEqual(viewModel.startButtonTitle, "Continue pre-ride check")
        XCTAssertNotNil(store.activeInspection())
    }

    func test_startOrContinueCheck_showsContinue_whenWalkAroundAlreadyInProgress() {
        store.save(.yamahaMT07())
        _ = try? StartPreRideInspectionUseCase(store: store).start()
        let viewModel = HomeViewModel(store: store)

        XCTAssertEqual(viewModel.startButtonTitle, "Continue pre-ride check")
        XCTAssertTrue(viewModel.startOrContinueCheck())
        XCTAssertNil(viewModel.riderError)
    }
}

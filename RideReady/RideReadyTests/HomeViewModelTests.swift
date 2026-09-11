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

    func test_reload_showsToday_whenLastCheckWasThisMorning() throws {
        _ = try StartPreRideInspectionUseCase(store: store).start()
        let record = RecordInspectionFindingUseCase(store: store)
        for item in Motorcycle.yamahaMT07().requiredInspectionItems() {
            try record.record(.ok, for: item)
        }
        _ = try CompletePreRideInspectionUseCase(store: store).complete(as: .readyToRide)

        let viewModel = HomeViewModel(store: store)

        XCTAssertTrue(viewModel.lastCheckText.hasPrefix("Last check: today,"))
        XCTAssertEqual(viewModel.streakText, "1 day streak")
        XCTAssertEqual(viewModel.startButtonTitle, "Start pre-ride check")
    }

    func test_reload_showsSetUpBike_whenMotorcycleIsMissing() {
        defaults.removePersistentDomain(forName: suiteName)
        store = UserDefaultsRideReadyStore(defaults: defaults)
        let viewModel = HomeViewModel(store: store)

        XCTAssertEqual(viewModel.motorcycleName, "No bike set up")
        XCTAssertEqual(viewModel.bikeProfileButtonTitle, "Set up your motorcycle")
    }
}

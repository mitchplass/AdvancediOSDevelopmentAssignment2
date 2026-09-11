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
        XCTAssertTrue(viewModel.isRideReady)
        XCTAssertEqual(viewModel.rideReadyTitle, "Ride ready")
    }

    func test_reload_showsNotRideReady_whenNoCheckHasBeenLogged() {
        let viewModel = HomeViewModel(store: store)

        XCTAssertFalse(viewModel.isRideReady)
        XCTAssertEqual(viewModel.rideReadyTitle, "Not ride ready")
        XCTAssertEqual(viewModel.rideReadyDetail, "Do a pre-ride check before you leave.")
    }

    func test_reload_showsNotRideReady_whenWalkAroundIsInProgress() throws {
        _ = try StartPreRideInspectionUseCase(store: store).start()
        let viewModel = HomeViewModel(store: store)

        XCTAssertFalse(viewModel.isRideReady)
        XCTAssertEqual(viewModel.rideReadyTitle, "Not ride ready")
        XCTAssertEqual(
            viewModel.rideReadyDetail,
            "Finish this walk-around before you treat the bike as ride ready."
        )
    }

    func test_reload_showsNotRideReady_whenLastWalkAroundNeededAttention() throws {
        try completeWalkAround(as: .notRideReady)
        let viewModel = HomeViewModel(store: store)

        XCTAssertFalse(viewModel.isRideReady)
        XCTAssertEqual(viewModel.rideReadyTitle, "Not ride ready")
        XCTAssertEqual(
            viewModel.rideReadyDetail,
            "Last walk-around found something that needs attention."
        )
    }

    func test_reload_showsNotRideReady_whenLastReadyCheckWasYesterday() throws {
        let yesterday = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -1, to: Date()))
        try completeWalkAround(as: .readyToRide, now: { yesterday })
        let viewModel = HomeViewModel(store: store)

        XCTAssertFalse(viewModel.isRideReady)
        XCTAssertEqual(viewModel.rideReadyTitle, "Not ride ready")
        XCTAssertEqual(viewModel.rideReadyDetail, "Do a pre-ride check before you leave.")
    }

    func test_reload_showsSetUpBike_whenMotorcycleIsMissing() {
        defaults.removePersistentDomain(forName: suiteName)
        store = UserDefaultsRideReadyStore(defaults: defaults)
        let viewModel = HomeViewModel(store: store)

        XCTAssertEqual(viewModel.motorcycleName, "No bike set up")
        XCTAssertEqual(viewModel.bikeProfileButtonTitle, "Set up your motorcycle")
    }

    func test_reload_showsBikePhoto_whenRiderHasSavedOne() {
        let photo = Data("home-bike".utf8)
        store.saveMotorcyclePhoto(photo)
        let viewModel = HomeViewModel(store: store)

        XCTAssertEqual(viewModel.motorcyclePhoto, photo)
    }

    private func completeWalkAround(
        as readiness: RideReadiness,
        now: @escaping () -> Date = Date.init
    ) throws {
        _ = try StartPreRideInspectionUseCase(store: store).start()
        let record = RecordInspectionFindingUseCase(store: store)
        let items = Motorcycle.yamahaMT07().requiredInspectionItems()
        for item in items {
            let result: InspectionResult = (readiness == .notRideReady && item == .tyres)
                ? .needsAttention
                : .ok
            try record.record(result, for: item)
        }
        _ = try CompletePreRideInspectionUseCase(store: store, now: now).complete(as: readiness)
    }
}

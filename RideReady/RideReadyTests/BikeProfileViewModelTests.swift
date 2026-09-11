import XCTest
@testable import RideReady

final class BikeProfileViewModelTests: XCTestCase {
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

    func test_save_updatesMotorcycle_whenRiderChangesNameAndPressures() {
        let viewModel = BikeProfileViewModel(store: store)
        viewModel.name = "Honda CB500F"
        viewModel.finalDrive = .chain
        viewModel.frontTyrePressurePSI = 32
        viewModel.rearTyrePressurePSI = 36
        viewModel.chainSlackMinMillimetres = 20
        viewModel.chainSlackMaxMillimetres = 30
        viewModel.photoData = Data("cb500-photo".utf8)

        viewModel.save()

        XCTAssertTrue(viewModel.didSave)
        XCTAssertEqual(store.motorcycle()?.name, "Honda CB500F")
        XCTAssertEqual(store.motorcycle()?.frontTyrePressurePSI, 32)
        XCTAssertEqual(store.motorcycle()?.rearTyrePressurePSI, 36)
        XCTAssertEqual(store.motorcycle()?.chainSlackMinMillimetres, 20)
        XCTAssertEqual(store.motorcycle()?.chainSlackMaxMillimetres, 30)
        XCTAssertEqual(store.motorcyclePhoto(), Data("cb500-photo".utf8))
    }

    func test_save_fails_whenNameIsMissing() {
        let viewModel = BikeProfileViewModel(store: store)
        viewModel.name = " "

        viewModel.save()

        XCTAssertFalse(viewModel.didSave)
        XCTAssertEqual(viewModel.riderError, SaveMotorcycleError.nameMissing.localizedDescription)
        XCTAssertEqual(store.motorcycle()?.name, "Yamaha MT-07")
    }

    func test_save_fails_whenWalkAroundIsInProgress() throws {
        _ = try StartPreRideInspectionUseCase(store: store).start()
        let viewModel = BikeProfileViewModel(store: store)
        viewModel.name = "Honda Gold Wing"
        viewModel.finalDrive = .shaft

        viewModel.save()

        XCTAssertFalse(viewModel.didSave)
        XCTAssertEqual(viewModel.riderError, SaveMotorcycleError.walkAroundInProgress.localizedDescription)
        XCTAssertEqual(store.motorcycle()?.name, "Yamaha MT-07")
    }
}

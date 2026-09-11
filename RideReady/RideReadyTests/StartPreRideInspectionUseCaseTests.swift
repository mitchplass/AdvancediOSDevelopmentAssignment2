import XCTest
@testable import RideReady

final class StartPreRideInspectionUseCaseTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!
    private var store: UserDefaultsRideReadyStore!
    private var useCase: StartPreRideInspectionUseCase!

    override func setUpWithError() throws {
        suiteName = "RideReadyTests.\(UUID().uuidString)"
        defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        store = UserDefaultsRideReadyStore(defaults: defaults)
        useCase = StartPreRideInspectionUseCase(store: store)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        store = nil
        useCase = nil
        suiteName = nil
    }

    func test_startInspection_createsWalkAround_whenMotorcycleIsSetUp() throws {
        store.save(Motorcycle.yamahaMT07())

        let inspection = try useCase.start()

        XCTAssertEqual(inspection.motorcycle.name, "Yamaha MT-07")
        XCTAssertTrue(inspection.findings.isEmpty)
        XCTAssertNil(inspection.completedAt)
        XCTAssertEqual(store.activeInspection()?.id, inspection.id)
    }

    func test_startInspection_fails_whenNoMotorcycleIsSetUp() {
        XCTAssertThrowsError(try useCase.start()) { error in
            XCTAssertEqual(error as? StartPreRideInspectionError, .motorcycleNotSetUp)
        }
    }

    func test_startInspection_fails_whenWalkAroundAlreadyInProgress() throws {
        store.save(Motorcycle.yamahaMT07())
        _ = try useCase.start()

        XCTAssertThrowsError(try useCase.start()) { error in
            XCTAssertEqual(error as? StartPreRideInspectionError, .inspectionAlreadyInProgress)
        }
    }

    func test_startInspection_buildsChainItem_forChainDriveMotorcycle() throws {
        store.save(Motorcycle.yamahaMT07())

        let inspection = try useCase.start()

        XCTAssertEqual(
            inspection.motorcycle.requiredInspectionItems(),
            [.tyres, .chain, .lights, .fluidsAndGear]
        )
    }

    func test_startInspection_omitsChain_forShaftDriveMotorcycle() throws {
        store.save(
            Motorcycle(
                name: "Honda Gold Wing",
                finalDrive: .shaft,
                frontTyrePressurePSI: 36,
                rearTyrePressurePSI: 42
            )
        )

        let inspection = try useCase.start()

        XCTAssertEqual(
            inspection.motorcycle.requiredInspectionItems(),
            [.tyres, .finalDrive, .lights, .fluidsAndGear]
        )
    }
}

import XCTest
@testable import RideReady

final class SaveMotorcycleUseCaseTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!
    private var store: UserDefaultsRideReadyStore!
    private var useCase: SaveMotorcycleUseCase!

    override func setUpWithError() throws {
        suiteName = "RideReadyTests.\(UUID().uuidString)"
        defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        store = UserDefaultsRideReadyStore(defaults: defaults)
        useCase = SaveMotorcycleUseCase(store: store)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        store = nil
        useCase = nil
        suiteName = nil
    }

    func test_saveMotorcycle_keepsTrimmedName_whenDetailsAreValid() throws {
        let saved = try useCase.save(
            Motorcycle(
                name: "  Honda CB500F  ",
                finalDrive: .chain,
                frontTyrePressurePSI: 32,
                rearTyrePressurePSI: 36
            )
        )

        XCTAssertEqual(saved.name, "Honda CB500F")
        XCTAssertEqual(store.motorcycle()?.name, "Honda CB500F")
        XCTAssertEqual(store.motorcycle()?.frontTyrePressurePSI, 32)
        XCTAssertEqual(store.motorcycle()?.rearTyrePressurePSI, 36)
    }

    func test_saveMotorcycle_fails_whenNameIsMissing() {
        let unnamed = Motorcycle(
            name: "   ",
            finalDrive: .chain,
            frontTyrePressurePSI: 36,
            rearTyrePressurePSI: 42
        )

        XCTAssertThrowsError(try useCase.save(unnamed)) { error in
            XCTAssertEqual(error as? SaveMotorcycleError, .nameMissing)
        }
        XCTAssertNil(store.motorcycle())
    }

    func test_saveMotorcycle_fails_whenTyrePressureIsOutOfRange() {
        let tooSoft = Motorcycle(
            name: "Yamaha MT-07",
            finalDrive: .chain,
            frontTyrePressurePSI: 19,
            rearTyrePressurePSI: 42
        )

        XCTAssertThrowsError(try useCase.save(tooSoft)) { error in
            XCTAssertEqual(error as? SaveMotorcycleError, .tyrePressureOutOfRange)
        }
    }

    func test_saveMotorcycle_fails_whenWalkAroundIsInProgress() throws {
        store.save(.yamahaMT07())
        _ = try StartPreRideInspectionUseCase(store: store).start()

        let updated = Motorcycle(
            name: "Honda Gold Wing",
            finalDrive: .shaft,
            frontTyrePressurePSI: 36,
            rearTyrePressurePSI: 42
        )

        XCTAssertThrowsError(try useCase.save(updated)) { error in
            XCTAssertEqual(error as? SaveMotorcycleError, .walkAroundInProgress)
        }
        XCTAssertEqual(store.motorcycle()?.name, "Yamaha MT-07")
    }

    func test_saveMotorcycle_switchesToShaftDrive_whenRiderChangesFinalDrive() throws {
        store.save(.yamahaMT07())

        _ = try useCase.save(
            Motorcycle(
                name: "Honda Gold Wing",
                finalDrive: .shaft,
                frontTyrePressurePSI: 36,
                rearTyrePressurePSI: 42
            )
        )

        let inspection = try StartPreRideInspectionUseCase(store: store).start()
        XCTAssertEqual(
            inspection.motorcycle.requiredInspectionItems(),
            [.tyres, .finalDrive, .lights, .fluidsAndGear]
        )
    }
}

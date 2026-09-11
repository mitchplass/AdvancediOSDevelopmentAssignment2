import XCTest
@testable import RideReady

final class RecordInspectionFindingUseCaseTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!
    private var store: UserDefaultsRideReadyStore!
    private var startInspection: StartPreRideInspectionUseCase!
    private var useCase: RecordInspectionFindingUseCase!

    override func setUpWithError() throws {
        suiteName = "RideReadyTests.\(UUID().uuidString)"
        defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        store = UserDefaultsRideReadyStore(defaults: defaults)
        startInspection = StartPreRideInspectionUseCase(store: store)
        useCase = RecordInspectionFindingUseCase(store: store)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        store = nil
        startInspection = nil
        useCase = nil
        suiteName = nil
    }

    func test_recordFinding_marksTyresOK_whenWalkAroundIsInProgress() throws {
        store.save(Motorcycle.yamahaMT07())
        _ = try startInspection.start()

        let inspection = try useCase.record(.ok, for: .tyres)

        XCTAssertEqual(inspection.findings.count, 1)
        XCTAssertEqual(inspection.findings[0].item, .tyres)
        XCTAssertEqual(inspection.findings[0].result, .ok)
    }

    func test_recordFinding_updatesResult_whenRiderChangesTyresToNeedsAttention() throws {
        store.save(Motorcycle.yamahaMT07())
        _ = try startInspection.start()
        _ = try useCase.record(.ok, for: .tyres)

        let inspection = try useCase.record(.needsAttention, for: .tyres)

        XCTAssertEqual(inspection.findings.count, 1)
        XCTAssertEqual(inspection.findings[0].result, .needsAttention)
    }

    func test_recordFinding_fails_whenWalkAroundHasNotStarted() {
        XCTAssertThrowsError(try useCase.record(.ok, for: .tyres)) { error in
            XCTAssertEqual(error as? RecordInspectionFindingError, .walkAroundNotStarted)
        }
    }

    func test_recordFinding_fails_whenChainIsRecordedOnShaftDriveMotorcycle() throws {
        store.save(
            Motorcycle(
                name: "Honda Gold Wing",
                finalDrive: .shaft,
                frontTyrePressurePSI: 36,
                rearTyrePressurePSI: 42
            )
        )
        _ = try startInspection.start()

        XCTAssertThrowsError(try useCase.record(.ok, for: .chain)) { error in
            XCTAssertEqual(error as? RecordInspectionFindingError, .itemNotOnThisBike(.chain))
        }
    }
}

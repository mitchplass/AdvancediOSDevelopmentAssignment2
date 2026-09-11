import XCTest
@testable import RideReady

final class UserDefaultsRideReadyStoreTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!
    private var store: UserDefaultsRideReadyStore!

    override func setUpWithError() throws {
        suiteName = "RideReadyTests.\(UUID().uuidString)"
        defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        store = UserDefaultsRideReadyStore(defaults: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        store = nil
        suiteName = nil
    }

    func test_saveMotorcycle_isStillThereAfterCreatingANewStore() {
        store.save(Motorcycle.yamahaMT07())

        let reloaded = UserDefaultsRideReadyStore(defaults: defaults)

        XCTAssertEqual(reloaded.motorcycle()?.name, "Yamaha MT-07")
        XCTAssertEqual(reloaded.motorcycle()?.finalDrive, .chain)
    }

    func test_completedInspection_isStillCompletedAfterCreatingANewStore() {
        var inspection = PreRideInspection(
            id: UUID(),
            motorcycle: Motorcycle.yamahaMT07(),
            startedAt: Date(),
            findings: []
        )
        inspection.completedAt = Date()
        inspection.readiness = .readyToRide
        store.save(inspection)

        let reloaded = UserDefaultsRideReadyStore(defaults: defaults)

        XCTAssertNil(reloaded.activeInspection())
        XCTAssertEqual(reloaded.latestCompletedInspection()?.id, inspection.id)
    }

    func test_saveStreak_isStillThereAfterCreatingANewStore() {
        store.save(SafetyStreak(consecutiveDays: 3, lastCompletedOn: Date()))

        let reloaded = UserDefaultsRideReadyStore(defaults: defaults)

        XCTAssertEqual(reloaded.streak().consecutiveDays, 3)
    }

    func test_activeInspection_isNil_afterInspectionIsCompleted() {
        var inspection = PreRideInspection(
            id: UUID(),
            motorcycle: Motorcycle.yamahaMT07(),
            startedAt: Date(),
            findings: []
        )

        store.save(inspection)
        XCTAssertEqual(store.activeInspection()?.id, inspection.id)

        inspection.completedAt = Date()
        inspection.readiness = .readyToRide
        store.save(inspection)

        XCTAssertNil(store.activeInspection())
        XCTAssertEqual(store.latestCompletedInspection()?.id, inspection.id)
    }
}

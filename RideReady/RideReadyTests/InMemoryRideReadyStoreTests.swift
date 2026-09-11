import XCTest
@testable import RideReady

final class InMemoryRideReadyStoreTests: XCTestCase {
    func test_saveMotorcycle_persistsProfileForInspectionStart() {
        let store = InMemoryRideReadyStore()
        let motorcycle = Motorcycle.yamahaMT07()

        store.save(motorcycle)

        XCTAssertEqual(store.motorcycle()?.name, "Yamaha MT-07")
        XCTAssertEqual(store.motorcycle()?.finalDrive, .chain)
    }

    func test_activeInspection_isNil_afterInspectionIsCompleted() {
        let store = InMemoryRideReadyStore()
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

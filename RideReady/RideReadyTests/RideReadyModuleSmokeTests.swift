import XCTest
@testable import RideReady

final class RideReadyModuleSmokeTests: XCTestCase {
    /// Confirms the unit-test bundle hosts the RideReady app module so later
    /// use-case tests can import domain types with `@testable import RideReady`.
    func test_testBundle_canLoadRideReadyAppModule() {
        XCTAssertNotNil(RideReadyApp.self)
    }
}

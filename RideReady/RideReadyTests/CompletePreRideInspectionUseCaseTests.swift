import XCTest
@testable import RideReady

final class CompletePreRideInspectionUseCaseTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!
    private var store: UserDefaultsRideReadyStore!
    private var startInspection: StartPreRideInspectionUseCase!
    private var recordFinding: RecordInspectionFindingUseCase!
    private var calendar: Calendar!

    override func setUpWithError() throws {
        suiteName = "RideReadyTests.\(UUID().uuidString)"
        defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        store = UserDefaultsRideReadyStore(defaults: defaults)
        startInspection = StartPreRideInspectionUseCase(store: store)
        recordFinding = RecordInspectionFindingUseCase(store: store)

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        self.calendar = calendar
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        store = nil
        startInspection = nil
        recordFinding = nil
        calendar = nil
        suiteName = nil
    }

    func test_completeInspection_marksRideReady_whenEveryItemIsOK() throws {
        try startWalkAround()
        try markAllItems(ok: true)

        let useCase = makeUseCase()
        let inspection = try useCase.complete(as: .readyToRide)

        XCTAssertEqual(inspection.readiness, .readyToRide)
        XCTAssertNotNil(inspection.completedAt)
        XCTAssertNil(store.activeInspection())
        XCTAssertEqual(store.streak().consecutiveDays, 1)
    }

    func test_completeInspection_fails_whenWalkAroundHasNotStarted() {
        let useCase = makeUseCase()

        XCTAssertThrowsError(try useCase.complete(as: .readyToRide)) { error in
            XCTAssertEqual(error as? CompletePreRideInspectionError, .walkAroundNotStarted)
        }
    }

    func test_completeInspection_fails_whenTyresAreUnchecked() throws {
        try startWalkAround()
        let items = Motorcycle.yamahaMT07().requiredInspectionItems().filter { $0 != .tyres }
        for item in items {
            _ = try recordFinding.record(.ok, for: item)
        }

        let useCase = makeUseCase()

        XCTAssertThrowsError(try useCase.complete(as: .readyToRide)) { error in
            XCTAssertEqual(error as? CompletePreRideInspectionError, .uncheckedItems([.tyres]))
        }
    }

    func test_completeInspection_blocksRideReady_whenChainNeedsAttention() throws {
        try startWalkAround()
        try markAllItems(ok: true)
        _ = try recordFinding.record(.needsAttention, for: .chain)

        let useCase = makeUseCase()

        XCTAssertThrowsError(try useCase.complete(as: .readyToRide)) { error in
            XCTAssertEqual(error as? CompletePreRideInspectionError, .itemNeedsAttention)
        }
    }

    func test_completeInspection_logsNotRideReady_whenChainNeedsAttention() throws {
        try startWalkAround()
        try markAllItems(ok: true)
        _ = try recordFinding.record(.needsAttention, for: .chain)

        let useCase = makeUseCase()
        let inspection = try useCase.complete(as: .notRideReady)

        XCTAssertEqual(inspection.readiness, .notRideReady)
        XCTAssertEqual(store.streak().consecutiveDays, 1)
    }

    func test_completeInspection_incrementsStreak_onConsecutiveCalendarDays() throws {
        let day1 = Date(timeIntervalSince1970: 1_704_067_200)
        let day2 = calendar.date(byAdding: .day, value: 1, to: day1)!

        try completeFullCheck(on: day1)
        try completeFullCheck(on: day2)

        XCTAssertEqual(store.streak().consecutiveDays, 2)
    }

    func test_completeInspection_doesNotDoubleCount_whenCompletedTwiceOnSameDay() throws {
        let day1 = Date(timeIntervalSince1970: 1_704_067_200)
        let laterSameDay = day1.addingTimeInterval(8 * 60 * 60)

        try completeFullCheck(on: day1)
        try completeFullCheck(on: laterSameDay)

        XCTAssertEqual(store.streak().consecutiveDays, 1)
        XCTAssertEqual(store.streak().lastCompletedOn, laterSameDay)
    }

    func test_completeInspection_resetsStreak_afterAMissedDay() throws {
        let day1 = Date(timeIntervalSince1970: 1_704_067_200)
        let day3 = calendar.date(byAdding: .day, value: 2, to: day1)!

        try completeFullCheck(on: day1)
        try completeFullCheck(on: day3)

        XCTAssertEqual(store.streak().consecutiveDays, 1)
    }

    private func makeUseCase(now: Date = Date()) -> CompletePreRideInspectionUseCase {
        CompletePreRideInspectionUseCase(
            store: store,
            now: { now },
            calendar: calendar
        )
    }

    private func startWalkAround() throws {
        store.save(Motorcycle.yamahaMT07())
        _ = try startInspection.start()
    }

    private func markAllItems(ok: Bool) throws {
        let result: InspectionResult = ok ? .ok : .needsAttention
        for item in Motorcycle.yamahaMT07().requiredInspectionItems() {
            _ = try recordFinding.record(result, for: item)
        }
    }

    private func completeFullCheck(on date: Date) throws {
        try startWalkAround()
        try markAllItems(ok: true)
        _ = try makeUseCase(now: date).complete(as: .readyToRide)
    }
}

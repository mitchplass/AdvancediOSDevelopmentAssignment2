import XCTest
@testable import RideReady

final class MotorcycleInspectionItemTests: XCTestCase {
    func test_requiredInspectionItems_includesChain_forChainDriveMotorcycle() {
        let motorcycle = Motorcycle.yamahaMT07()

        XCTAssertEqual(
            motorcycle.requiredInspectionItems(),
            [.tyres, .chain, .lights, .fluidsAndGear]
        )
    }

    func test_requiredInspectionItems_omitsChain_forShaftDriveMotorcycle() {
        let motorcycle = Motorcycle(
            name: "Honda Gold Wing",
            finalDrive: .shaft,
            frontTyrePressurePSI: 36,
            rearTyrePressurePSI: 42
        )

        XCTAssertEqual(
            motorcycle.requiredInspectionItems(),
            [.tyres, .finalDrive, .lights, .fluidsAndGear]
        )
    }

    func test_tyreGuidance_usesMotorcyclePressures() {
        let motorcycle = Motorcycle.yamahaMT07()
        let guidance = InspectionItem.tyres.guidance(for: motorcycle)

        XCTAssertTrue(guidance.contains("36 psi"))
        XCTAssertTrue(guidance.contains("42 psi"))
    }
}

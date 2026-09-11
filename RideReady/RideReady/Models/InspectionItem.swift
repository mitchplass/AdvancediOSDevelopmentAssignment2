import Foundation

/// A check that belongs on a pre-ride walk-around for some motorcycles.
protocol RideSafetyCheckable {
    var title: String { get }
    func guidance(for motorcycle: Motorcycle) -> String
    func isRequired(on motorcycle: Motorcycle) -> Bool
}

/// A single pre-ride safety check the rider must complete.
///
/// Business Rule: chain bikes include a chain check; shaft and belt bikes
/// include a final-drive check instead.
enum InspectionItem: String, CaseIterable, Codable {
    case tyres
    case chain
    case finalDrive
    case lights
    case fluidsAndGear

    var title: String {
        switch self {
        case .tyres: return "Tyres"
        case .chain: return "Chain"
        case .finalDrive: return "Final drive"
        case .lights: return "Lights"
        case .fluidsAndGear: return "Fluids and gear"
        }
    }

    func guidance(for motorcycle: Motorcycle) -> String {
        switch self {
        case .tyres:
            return "Check front \(motorcycle.frontTyrePressurePSI) psi and rear \(motorcycle.rearTyrePressurePSI) psi."
        case .chain:
            if let min = motorcycle.chainSlackMinMillimetres,
               let max = motorcycle.chainSlackMaxMillimetres {
                return "Check lubrication and slack. Slack should be \(min)–\(max) mm."
            }
            return "Check tension and lubrication."
        case .finalDrive:
            if motorcycle.finalDrive == .shaft {
                return "Look for oil leaks around the shaft housing."
            }
            return "Check the belt for cracks or missing teeth."
        case .lights:
            return "Check headlight, tail light, brake light, and both indicators."
        case .fluidsAndGear:
            return "Check oil, brake fluid, helmet, visor, jacket, and gloves."
        }
    }

    func isRequired(on motorcycle: Motorcycle) -> Bool {
        switch self {
        case .chain:
            return motorcycle.finalDrive == .chain
        case .finalDrive:
            return motorcycle.finalDrive != .chain
        case .tyres, .lights, .fluidsAndGear:
            return true
        }
    }
}

extension InspectionItem: RideSafetyCheckable {}

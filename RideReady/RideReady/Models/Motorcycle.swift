import Foundation

/// How power reaches the rear wheel: chain, shaft, or belt.
///
/// Business Rule: only chain motorcycles require a chain inspection item.
enum FinalDrive: String, Codable, CaseIterable {
    case chain
    case shaft
    case belt

    var title: String {
        switch self {
        case .chain: return "Chain"
        case .shaft: return "Shaft"
        case .belt: return "Belt"
        }
    }
}

/// The motorbike the rider inspects before a ride.
///
/// Business Rule: the checklist must match `finalDrive` so chain riders are
/// asked about the chain and shaft riders are not.
struct Motorcycle: Codable {
    var name: String
    var finalDrive: FinalDrive
    var frontTyrePressurePSI: Int
    var rearTyrePressurePSI: Int

    static func yamahaMT07() -> Motorcycle {
        Motorcycle(
            name: "Yamaha MT-07",
            finalDrive: .chain,
            frontTyrePressurePSI: 36,
            rearTyrePressurePSI: 42
        )
    }

    func requiredInspectionItems() -> [InspectionItem] {
        InspectionItem.allCases.filter { $0.isRequired(on: self) }
    }
}

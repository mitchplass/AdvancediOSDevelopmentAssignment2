import Foundation

/// Saves the rider's motorcycle so the next walk-around matches that bike.
///
/// Business Rule: the bike needs a name and tyre pressures between 20 and 50 psi.
/// Chain bikes also need a slack range. The profile cannot change while a
/// walk-around is already in progress.
struct SaveMotorcycleUseCase {
    static let tyrePressureRange = 20...50
    static let chainSlackRange = 10...60

    let store: RideReadyStoring

    func save(_ motorcycle: Motorcycle, photo: Data? = nil, replacingPhoto: Bool = false) throws -> Motorcycle {
        let name = motorcycle.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            throw SaveMotorcycleError.nameMissing
        }

        guard Self.tyrePressureRange.contains(motorcycle.frontTyrePressurePSI),
              Self.tyrePressureRange.contains(motorcycle.rearTyrePressurePSI) else {
            throw SaveMotorcycleError.tyrePressureOutOfRange
        }

        var minSlack = motorcycle.chainSlackMinMillimetres
        var maxSlack = motorcycle.chainSlackMaxMillimetres
        if motorcycle.finalDrive == .chain {
            let min = minSlack ?? 25
            let max = maxSlack ?? 35
            guard Self.chainSlackRange.contains(min),
                  Self.chainSlackRange.contains(max),
                  min <= max else {
                throw SaveMotorcycleError.chainSlackOutOfRange
            }
            minSlack = min
            maxSlack = max
        } else {
            minSlack = nil
            maxSlack = nil
        }

        if store.activeInspection() != nil {
            throw SaveMotorcycleError.walkAroundInProgress
        }

        let saved = Motorcycle(
            name: name,
            finalDrive: motorcycle.finalDrive,
            frontTyrePressurePSI: motorcycle.frontTyrePressurePSI,
            rearTyrePressurePSI: motorcycle.rearTyrePressurePSI,
            chainSlackMinMillimetres: minSlack,
            chainSlackMaxMillimetres: maxSlack
        )
        store.save(saved)
        if replacingPhoto {
            store.saveMotorcyclePhoto(photo)
        }
        return saved
    }
}

/// Failures when Alex tries to save or change the motorcycle profile.
enum SaveMotorcycleError: LocalizedError, Equatable {
    case nameMissing
    case tyrePressureOutOfRange
    case chainSlackOutOfRange
    case walkAroundInProgress

    var errorDescription: String? {
        switch self {
        case .nameMissing:
            return "Give this motorcycle a name so you know which bike you are checking."
        case .tyrePressureOutOfRange:
            return "Tyre pressures need to be between 20 and 50 psi. Check the sidewall or the owner's manual."
        case .chainSlackOutOfRange:
            return "Chain slack needs a min and max between 10 and 60 mm, with the min no higher than the max. Check the owner's manual."
        case .walkAroundInProgress:
            return "You already have a pre-ride check in progress. Finish that walk-around before you change the bike."
        }
    }
}

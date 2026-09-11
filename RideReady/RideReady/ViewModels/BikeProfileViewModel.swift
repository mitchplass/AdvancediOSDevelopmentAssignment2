import Combine
import Foundation

/// Bike profile state: name, final drive, and tyre pressures.
final class BikeProfileViewModel: ObservableObject {
    @Published var name: String
    @Published var finalDrive: FinalDrive
    @Published var frontTyrePressurePSI: Int
    @Published var rearTyrePressurePSI: Int
    @Published var riderError: String?
    @Published var didSave = false

    let tyrePressureRange = SaveMotorcycleUseCase.tyrePressureRange

    private let saveMotorcycle: SaveMotorcycleUseCase

    init(store: RideReadyStoring) {
        saveMotorcycle = SaveMotorcycleUseCase(store: store)
        let bike = store.motorcycle()
        name = bike?.name ?? ""
        finalDrive = bike?.finalDrive ?? .chain
        frontTyrePressurePSI = bike?.frontTyrePressurePSI ?? 36
        rearTyrePressurePSI = bike?.rearTyrePressurePSI ?? 42
    }

    func save() {
        riderError = nil
        didSave = false
        do {
            let saved = try saveMotorcycle.save(
                Motorcycle(
                    name: name,
                    finalDrive: finalDrive,
                    frontTyrePressurePSI: frontTyrePressurePSI,
                    rearTyrePressurePSI: rearTyrePressurePSI
                )
            )
            name = saved.name
            didSave = true
        } catch {
            riderError = error.localizedDescription
        }
    }
}

import Combine
import UIKit

/// Bike profile state: name, photo, final drive, tyre pressures, and chain slack.
final class BikeProfileViewModel: ObservableObject {
    @Published var name: String
    @Published var photoData: Data?
    @Published var finalDrive: FinalDrive
    @Published var frontTyrePressurePSI: Int
    @Published var rearTyrePressurePSI: Int
    @Published var chainSlackMinMillimetres: Int
    @Published var chainSlackMaxMillimetres: Int
    @Published var riderError: String?
    @Published var didSave = false

    let tyrePressureRange = SaveMotorcycleUseCase.tyrePressureRange
    let chainSlackRange = SaveMotorcycleUseCase.chainSlackRange

    private let saveMotorcycle: SaveMotorcycleUseCase

    init(store: RideReadyStoring) {
        saveMotorcycle = SaveMotorcycleUseCase(store: store)
        let bike = store.motorcycle()
        name = bike?.name ?? ""
        photoData = store.motorcyclePhoto()
        finalDrive = bike?.finalDrive ?? .chain
        frontTyrePressurePSI = bike?.frontTyrePressurePSI ?? 36
        rearTyrePressurePSI = bike?.rearTyrePressurePSI ?? 42
        chainSlackMinMillimetres = bike?.chainSlackMinMillimetres ?? 25
        chainSlackMaxMillimetres = bike?.chainSlackMaxMillimetres ?? 35
    }

    func setPhoto(from data: Data) {
        photoData = Self.jpegDataForStorage(from: data)
    }

    func removePhoto() {
        photoData = nil
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
                    rearTyrePressurePSI: rearTyrePressurePSI,
                    chainSlackMinMillimetres: finalDrive == .chain ? chainSlackMinMillimetres : nil,
                    chainSlackMaxMillimetres: finalDrive == .chain ? chainSlackMaxMillimetres : nil
                ),
                photo: photoData,
                replacingPhoto: true
            )
            name = saved.name
            didSave = true
        } catch {
            riderError = error.localizedDescription
        }
    }

    private static func jpegDataForStorage(from data: Data) -> Data {
        guard let image = UIImage(data: data) else { return data }
        let maxDimension: CGFloat = 900
        let longest = max(image.size.width, image.size.height)
        let scale = longest > maxDimension ? maxDimension / longest : 1
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: size)
        let scaled = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return scaled.jpegData(compressionQuality: 0.7) ?? data
    }
}

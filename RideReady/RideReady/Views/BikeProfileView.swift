import SwiftUI

struct BikeProfileView: View {
    @StateObject private var viewModel: BikeProfileViewModel
    @Binding var path: [RideReadyRoute]
    @State private var showingError = false

    init(store: RideReadyStoring, path: Binding<[RideReadyRoute]>) {
        _viewModel = StateObject(wrappedValue: BikeProfileViewModel(store: store))
        _path = path
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Bike name")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            TextField("Yamaha MT-07", text: $viewModel.name)
                .textFieldStyle(.roundedBorder)

            Text("Final drive")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Picker("Final drive", selection: $viewModel.finalDrive) {
                ForEach(FinalDrive.allCases, id: \.self) { drive in
                    Text(drive.title).tag(drive)
                }
            }
            .pickerStyle(.segmented)

            VStack(alignment: .leading, spacing: 8) {
                Text("Front tyre")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Stepper(
                    "\(viewModel.frontTyrePressurePSI) psi",
                    value: $viewModel.frontTyrePressurePSI,
                    in: viewModel.tyrePressureRange
                )
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.background, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(uiColor: .separator), lineWidth: 1)
            )

            VStack(alignment: .leading, spacing: 8) {
                Text("Rear tyre")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Stepper(
                    "\(viewModel.rearTyrePressurePSI) psi",
                    value: $viewModel.rearTyrePressurePSI,
                    in: viewModel.tyrePressureRange
                )
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.background, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(uiColor: .separator), lineWidth: 1)
            )

            Text("The next walk-around will use this bike's checks and tyre pressures.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Spacer()

            Button("Save bike") {
                viewModel.save()
                if viewModel.didSave {
                    path.removeLast()
                } else {
                    showingError = viewModel.riderError != nil
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(maxWidth: .infinity)
        }
        .padding(24)
        .navigationTitle("Bike profile")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Can't save this bike", isPresented: $showingError, actions: {
            Button("OK", role: .cancel) {}
        }, message: {
            Text(viewModel.riderError ?? "")
        })
    }
}

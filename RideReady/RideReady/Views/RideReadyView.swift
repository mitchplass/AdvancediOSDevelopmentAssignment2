import SwiftUI

struct RideReadyView: View {
    @StateObject private var viewModel: RideReadyViewModel
    @Binding var path: [RideReadyRoute]
    @State private var showingError = false

    init(store: RideReadyStoring, path: Binding<[RideReadyRoute]>) {
        _viewModel = StateObject(wrappedValue: RideReadyViewModel(store: store))
        _path = path
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: viewModel.isRideReady ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 56))
                .foregroundStyle(viewModel.isRideReady ? Color.green : Color.accentColor)
            Text(viewModel.headline)
                .font(.title.bold())
            Text(viewModel.detail)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Spacer()
            Button(viewModel.logButtonTitle) {
                viewModel.logRide()
                if viewModel.didLog {
                    path.removeAll()
                } else {
                    showingError = viewModel.riderError != nil
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(maxWidth: .infinity)
        }
        .padding(24)
        .navigationTitle("Ride ready")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Can't log this ride", isPresented: $showingError, actions: {
            Button("OK", role: .cancel) {}
        }, message: {
            Text(viewModel.riderError ?? "")
        })
    }
}

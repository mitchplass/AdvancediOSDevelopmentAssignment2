import SwiftUI

enum RideReadyRoute: Hashable {
    case checklist
    case itemDetail(InspectionItem)
    case rideReady
}

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @State private var showingError = false
    @State private var checkStarted = false

    init(store: RideReadyStoring) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(store: store))
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text(viewModel.motorcycleName)
                    .font(.largeTitle.bold())

                Text(viewModel.streakText)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.accentColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.accentColor.opacity(0.12), in: Capsule())

                Text(viewModel.lastCheckText)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.background, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(uiColor: .separator), lineWidth: 1)
                    )

                if checkStarted {
                    Text("Walk-around started. Open the checklist to inspect the bike.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(viewModel.startButtonTitle) {
                    if viewModel.startOrContinueCheck() {
                        checkStarted = true
                        viewModel.reload()
                    } else {
                        showingError = viewModel.riderError != nil
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
            }
            .padding(24)
            .navigationTitle("RideReady")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { viewModel.reload() }
            .alert("Can't start this check", isPresented: $showingError, actions: {
                Button("OK", role: .cancel) {}
            }, message: {
                Text(viewModel.riderError ?? "")
            })
        }
    }
}

#Preview {
    let store = UserDefaultsRideReadyStore()
    if store.motorcycle() == nil {
        store.save(.yamahaMT07())
    }
    return HomeView(store: store)
}

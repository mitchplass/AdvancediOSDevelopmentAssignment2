import SwiftUI

struct ItemDetailView: View {
    @StateObject private var viewModel: ItemDetailViewModel
    @State private var showingError = false

    init(item: InspectionItem, store: RideReadyStoring) {
        _viewModel = StateObject(wrappedValue: ItemDetailViewModel(item: item, store: store))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(viewModel.guidance)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.background, in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(uiColor: .separator), lineWidth: 1)
                )

            HStack(spacing: 12) {
                resultButton(title: "OK", result: .ok)
                resultButton(title: "Issue", result: .needsAttention)
            }

            Spacer()
        }
        .padding(24)
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Can't record this check", isPresented: $showingError, actions: {
            Button("OK", role: .cancel) {}
        }, message: {
            Text(viewModel.riderError ?? "")
        })
        .onChange(of: viewModel.riderError) { _, newValue in
            showingError = newValue != nil
        }
    }

    private func resultButton(title: String, result: InspectionResult) -> some View {
        let isSelected = viewModel.selectedResult == result
        return Button(title) {
            if result == .ok {
                viewModel.markOK()
            } else {
                viewModel.markIssue()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(isSelected ? Color.accentColor : Color.clear, in: RoundedRectangle(cornerRadius: 10))
        .foregroundStyle(isSelected ? Color.white : Color.primary)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.accentColor : Color(uiColor: .separator), lineWidth: 1)
        )
    }
}

import SwiftUI

struct ChecklistView: View {
    @StateObject private var viewModel: ChecklistViewModel
    @Binding var path: [RideReadyRoute]

    init(store: RideReadyStoring, path: Binding<[RideReadyRoute]>) {
        _viewModel = StateObject(wrappedValue: ChecklistViewModel(store: store))
        _path = path
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ProgressView(value: progress)
                .tint(Color.accentColor)
            Text(viewModel.progressText)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ForEach(viewModel.rows) { row in
                Button {
                    path.append(.itemDetail(row.item))
                } label: {
                    HStack {
                        Image(systemName: row.isComplete ? "checkmark.square.fill" : "square")
                            .foregroundStyle(row.isComplete ? .green : .secondary)
                        Text(row.title)
                            .foregroundStyle(.primary)
                        Spacer()
                        if row.needsAttention {
                            Text("Issue")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                    .padding()
                    .background(.background, in: RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(row.needsAttention ? Color.accentColor : Color(uiColor: .separator), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
        .padding(24)
        .navigationTitle("Pre-ride check")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.reload() }
    }

    private var progress: Double {
        guard !viewModel.rows.isEmpty else { return 0 }
        let done = viewModel.rows.filter(\.isComplete).count
        return Double(done) / Double(viewModel.rows.count)
    }
}

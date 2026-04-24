import SwiftUI

struct MoreView: View {
    var body: some View {
        List {
            Section("Safety") {
                NavigationLink {
                    EmergencyView()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "cross.case.fill")
                            .font(.title3)
                            .foregroundStyle(.red)
                            .symbolRenderingMode(.hierarchical)
                            .frame(width: 28)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Emergency")
                                .font(.body)
                            Text("Contacts & protocols")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("More")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        MoreView()
    }
}

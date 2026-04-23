import SwiftUI

struct SanctuaryCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    VStack(spacing: 16) {
        SanctuaryCard {
            Text("Card Title")
                .font(.headline)
            Text("This is a reusable card component for the sanctuary app.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }

        SanctuaryCard {
            HStack {
                Image(systemName: "pawprint.fill")
                    .foregroundStyle(.orange)
                    .symbolRenderingMode(.hierarchical)
                Text("Animals in Care")
                    .font(.headline)
                Spacer()
                Text("24")
                    .font(.title2.bold())
                    .monospacedDigit()
            }
        }
    }
    .padding(16)
}

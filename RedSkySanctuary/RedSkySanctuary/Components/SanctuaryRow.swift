import SwiftUI

struct SanctuaryRow<Trailing: View>: View {
    let iconName: String
    var iconColor: Color = .blue
    let title: String
    var subtitle: String? = nil
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundStyle(iconColor)
                .symbolRenderingMode(.hierarchical)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                Text(subtitle ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .opacity(subtitle == nil ? 0 : 1)
            }

            Spacer()

            trailing()
        }
        .padding(.vertical, 8)
    }
}

private struct DefaultChevron: View {
    var body: some View {
        Image(systemName: "chevron.right")
            .font(.caption)
            .foregroundStyle(.tertiary)
    }
}

extension SanctuaryRow where Trailing == DefaultChevron {
    init(
        iconName: String,
        iconColor: Color = .blue,
        title: String,
        subtitle: String? = nil
    ) {
        self.iconName = iconName
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.trailing = { DefaultChevron() }
    }
}

#Preview {
    VStack(spacing: 0) {
        SanctuaryRow(
            iconName: "heart.fill",
            iconColor: .red,
            title: "Health Records",
            subtitle: "View medical history"
        )

        Divider()

        SanctuaryRow(
            iconName: "bell.fill",
            iconColor: .orange,
            title: "Notifications"
        ) {
            Toggle("", isOn: .constant(true))
                .labelsHidden()
        }

        Divider()

        SanctuaryRow(
            iconName: "star.fill",
            iconColor: .yellow,
            title: "Favorites",
            subtitle: "3 animals"
        )
    }
    .padding(.horizontal, 16)
}

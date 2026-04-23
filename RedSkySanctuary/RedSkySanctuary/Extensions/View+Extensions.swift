import SwiftUI

// MARK: - View Modifiers

extension View {
    /// Applies the standard Sanctuary card style: surface background, rounded corners, internal padding.
    func sanctuaryCard() -> some View {
        self
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: 12, style: .continuous))
    }

    /// Applies the standard section header typography.
    func sectionHeader() -> some View {
        self
            .font(.system(.title3, design: .rounded).bold())
    }
}

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == ScaleButtonStyle {
    static var scale: ScaleButtonStyle { ScaleButtonStyle() }
}

import SwiftUI

struct EmptyStateView: View {
    let title: String
    let systemImage: String
    let description: String

    var body: some View {
        ContentUnavailableView(
            title,
            systemImage: systemImage,
            description: Text(description)
        )
    }
}

#Preview {
    EmptyStateView(
        title: "No Animals Yet",
        systemImage: "pawprint",
        description: "Animals you add will appear here."
    )
}

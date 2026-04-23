import SwiftUI

struct MoreView: View {
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.system(size: 48))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.blue)
                
                Text("More")
                    .font(.system(.title3, design: .rounded).bold())
                    .foregroundStyle(.primary)
                
                Text("Coming Soon")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topCenter)
        .padding(16)
        .background(Color(.systemBackground))
        .navigationTitle("More")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        MoreView()
    }
}

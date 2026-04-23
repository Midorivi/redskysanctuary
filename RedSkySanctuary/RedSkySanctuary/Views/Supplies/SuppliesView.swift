import SwiftUI

struct SuppliesView: View {
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 48))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.blue)
                
                Text("Supplies")
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
        .navigationTitle("Supplies")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        SuppliesView()
    }
}
